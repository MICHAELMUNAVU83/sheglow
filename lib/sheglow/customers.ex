defmodule Sheglow.Customers do
  import Ecto.Query

  alias Sheglow.Repo
  alias Sheglow.Customers.Customer
  alias Sheglow.Orders.Order

  # ── Upsert from a paid order ──────────────────────────────────────────────

  @doc """
  Creates or updates a customer record from a paid order.
  On conflict by email: bumps order_count and total_spent.
  """
  def upsert_from_order(%Order{} = order) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    attrs = %{
      email: order.email,
      name: order.name,
      phone: order.phone,
      address: order.address,
      order_count: 1,
      total_spent: order.total_amount,
      inserted_at: now,
      updated_at: now
    }

    Repo.insert(
      %Customer{} |> Customer.changeset(attrs),
      on_conflict: [
        inc: [order_count: 1, total_spent: order.total_amount],
        set: [
          name: order.name,
          phone: order.phone || "",
          address: order.address || "",
          updated_at: now
        ]
      ],
      conflict_target: :email,
      returning: true
    )
  end

  # ── Queries ───────────────────────────────────────────────────────────────

  def list_customers(search \\ "") do
    Customer
    |> filter_search(search)
    |> order_by([c], desc: c.total_spent)
    |> Repo.all()
  end

  defp filter_search(query, s) when s in [nil, ""], do: query

  defp filter_search(query, term) do
    t = "%#{term}%"
    where(query, [c], ilike(c.email, ^t) or ilike(c.name, ^t) or ilike(c.phone, ^t))
  end

  def get_customer!(id), do: Repo.get!(Customer, id)

  def get_customer_by_email(email), do: Repo.get_by(Customer, email: email)

  @doc "All paid orders for this customer, newest first."
  def list_orders_for_customer(email) do
    from(o in Order,
      where: o.email == ^email and o.status == "paid",
      order_by: [desc: o.inserted_at]
    )
    |> Repo.all()
  end

  @doc "All orders (any status) for this customer."
  def list_all_orders_for_customer(email) do
    from(o in Order,
      where: o.email == ^email,
      order_by: [desc: o.inserted_at]
    )
    |> Repo.all()
  end

  def count_customers, do: Repo.aggregate(Customer, :count)
end
