defmodule Sheglow.Orders do
  import Ecto.Query

  alias Sheglow.Repo
  alias Sheglow.Orders.Order
  alias Sheglow.ProductVariants.ProductVariant
  alias Sheglow.Customers

  @all_statuses ~w(pending paid processing shipped delivered cancelled failed)
  # Statuses shown in admin — excludes "pending" (pre-payment, incomplete)
  @visible_statuses ~w(paid processing shipped delivered cancelled failed)

  # ── CRUD ──────────────────────────────────────────────────────────────────

  def create_order(attrs) do
    case %Order{} |> Order.changeset(attrs) |> Repo.insert() do
      {:ok, order} = result ->
        if order.promo_code not in [nil, ""] do
          Task.start(fn -> Sheglow.Promotions.record_usage(order.promo_code) end)
        end
        result
      error -> error
    end
  end

  def get_order!(id), do: Repo.get!(Order, id)

  def get_order_by_reference(reference) do
    Repo.get_by(Order, reference: reference)
  end

  def list_orders do
    Order
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
  end

  def list_orders_filtered(status, search) do
    Order
    |> filter_by_status(status)
    |> filter_by_search(search)
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
  end

  # "all" → show everything except pending
  defp filter_by_status(query, s) when s in [nil, "", "all"] do
    where(query, [o], o.status != "pending")
  end

  defp filter_by_status(query, status) when status in @all_statuses do
    where(query, [o], o.status == ^status)
  end

  defp filter_by_status(query, _), do: where(query, [o], o.status != "pending")

  defp filter_by_search(query, s) when s in [nil, ""], do: query

  defp filter_by_search(query, term) do
    t = "%#{term}%"

    where(
      query,
      [o],
      ilike(o.reference, ^t) or ilike(o.email, ^t) or
        ilike(o.name, ^t) or ilike(o.phone, ^t)
    )
  end

  # ── Status management ─────────────────────────────────────────────────────

  def update_status(%Order{status: same} = order, same), do: {:ok, order}

  def update_status(order, status) do
    Repo.transaction(fn ->
      case order |> Order.changeset(%{status: status}) |> Repo.update() do
        {:ok, updated} ->
          if status == "paid" && order.status != "paid" do
            deduct_stock_for_order(updated)
            Task.start(fn -> Customers.upsert_from_order(updated) end)
          end

          updated

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def mark_paid(order), do: update_status(order, "paid")
  def mark_failed(order), do: update_status(order, "failed")

  # ── Stock deduction ───────────────────────────────────────────────────────

  @doc """
  Deducts stock from `product_variants` for each line item in the order.
  Matches variants by product_id + color_name + size.
  """
  def deduct_stock_for_order(%Order{items: items}) when is_list(items) do
    Enum.each(items, fn item ->
      product_id = item["id"]
      color_name = item["color"]
      size = item["size"]
      qty = item["quantity"] || 1

      # Find all variants matching this product + colour + size
      from(pv in ProductVariant,
        where:
          pv.product_id == ^product_id and
            pv.color_name == ^color_name and
            pv.size == ^size
      )
      |> Repo.all()
      |> Enum.each(fn pv ->
        current = pv.stock_quantity |> parse_stock()
        new_qty = max(0, current - qty) |> Integer.to_string()

        pv
        |> ProductVariant.changeset(%{stock_quantity: new_qty})
        |> Repo.update()
      end)
    end)
  end

  def deduct_stock_for_order(_), do: :ok

  defp parse_stock(nil), do: 0
  defp parse_stock(""), do: 0

  defp parse_stock(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end

  defp parse_stock(n) when is_integer(n), do: n

  # ── Counts ────────────────────────────────────────────────────────────────

  def count_by_status do
    counts =
      from(o in Order,
        where: o.status != "pending",
        group_by: o.status,
        select: {o.status, count(o.id)}
      )
      |> Repo.all()
      |> Map.new()

    Map.put(counts, "all", Enum.sum(Map.values(counts)))
  end

  def count_pending do
    from(o in Order, where: o.status == "pending", select: count(o.id))
    |> Repo.one()
  end

  @doc "How many distinct orders contain this product."
  def count_orders_for_product(product_id) do
    product_id_str = to_string(product_id)

    # items is stored as jsonb[] (array of maps); use unnest to expand it
    from(o in Order,
      where:
        fragment(
          "EXISTS (SELECT 1 FROM unnest(?) AS item WHERE item->>'id' = ?)",
          o.items,
          ^product_id_str
        ),
      select: count(o.id)
    )
    |> Repo.one()
  end

  # ── Dashboard analytics ───────────────────────────────────────────────────

  @doc "Daily revenue for the last `days` days (non-pending orders only)."
  def daily_revenue(days \\ 30) do
    since = DateTime.utc_now() |> DateTime.add(-days * 86_400, :second)

    rows =
      from(o in Order,
        where: o.status != "pending" and o.inserted_at >= ^since,
        group_by: fragment("DATE(?)", o.inserted_at),
        order_by: fragment("DATE(?)", o.inserted_at),
        select: {fragment("DATE(?)", o.inserted_at), sum(o.total_amount)}
      )
      |> Repo.all()

    # Fill every day in the range with 0 if missing
    today = Date.utc_today()
    all_days = Enum.map(0..(days - 1), fn n -> Date.add(today, -(days - 1 - n)) end)
    row_map = Map.new(rows, fn {d, v} -> {d, v || 0} end)
    Enum.map(all_days, fn d -> {d, Map.get(row_map, d, 0)} end)
  end

  @doc "Revenue and order count grouped by status (non-pending)."
  def revenue_by_status do
    from(o in Order,
      where: o.status != "pending",
      group_by: o.status,
      select: {o.status, sum(o.total_amount), count(o.id)}
    )
    |> Repo.all()
  end

  @doc "Top N products by total revenue across all paid orders."
  def top_products_by_revenue(limit \\ 8) do
    {:ok, %{rows: rows}} =
      Repo.query(
        """
        SELECT
          item->>'name'  AS name,
          SUM((item->>'price')::numeric * (item->>'quantity')::int)::bigint AS revenue,
          SUM((item->>'quantity')::int)  AS qty
        FROM orders, unnest(items) AS item
        WHERE status != 'pending'
          AND item->>'name' IS NOT NULL
        GROUP BY item->>'name'
        ORDER BY revenue DESC
        LIMIT $1
        """,
        [limit]
      )

    Enum.map(rows, fn [name, rev, qty] -> %{name: name, revenue: rev || 0, qty: qty || 0} end)
  end

  @doc "Total revenue from all non-pending orders."
  def total_revenue do
    from(o in Order, where: o.status != "pending", select: sum(o.total_amount))
    |> Repo.one()
    |> Kernel.||(0)
  end

  @doc "Total count of non-pending orders."
  def total_orders do
    from(o in Order, where: o.status != "pending", select: count(o.id))
    |> Repo.one()
  end

  @doc "Average order value across non-pending orders."
  def average_order_value do
    from(o in Order, where: o.status != "pending", select: avg(o.total_amount))
    |> Repo.one()
    |> case do
      nil -> 0
      v -> round(Decimal.to_float(v))
    end
  end

  @doc "Most recent N non-pending orders."
  def recent_orders(limit \\ 5) do
    from(o in Order,
      where: o.status != "pending",
      order_by: [desc: o.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  def all_statuses, do: @all_statuses
  def visible_statuses, do: @visible_statuses

  def generate_reference do
    "KUL-#{:crypto.strong_rand_bytes(6) |> Base.encode16()}"
  end
end
