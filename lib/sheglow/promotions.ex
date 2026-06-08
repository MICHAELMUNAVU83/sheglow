defmodule Sheglow.Promotions do
  import Ecto.Query

  alias Sheglow.Repo
  alias Sheglow.Promotions.PromoCode

  # ── CRUD ──────────────────────────────────────────────────────────────────

  def list_promo_codes do
    PromoCode
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  def get_promo_code!(id), do: Repo.get!(PromoCode, id)

  def get_promo_code_by_code(code) when is_binary(code) do
    Repo.get_by(PromoCode, code: String.upcase(String.trim(code)))
  end

  def create_promo_code(attrs) do
    %PromoCode{}
    |> PromoCode.changeset(attrs)
    |> Repo.insert()
  end

  def update_promo_code(%PromoCode{} = promo, attrs) do
    promo
    |> PromoCode.changeset(attrs)
    |> Repo.update()
  end

  def delete_promo_code(%PromoCode{} = promo) do
    Repo.delete(promo)
  end

  def count_promo_codes, do: Repo.aggregate(PromoCode, :count)

  # ── Validation (checkout) ─────────────────────────────────────────────────

  @doc """
  Returns {:ok, promo} if the code is valid, {:error, reason_string} otherwise.
  """
  def validate_code(code) when is_binary(code) and code != "" do
    case get_promo_code_by_code(code) do
      nil ->
        {:error, "Promo code not found."}

      promo ->
        cond do
          not promo.is_active ->
            {:error, "This promo code is not active."}

          not is_nil(promo.expires_at) and
              DateTime.compare(DateTime.utc_now(), promo.expires_at) == :gt ->
            {:error, "This promo code has expired."}

          not is_nil(promo.max_uses) and promo.usage_count >= promo.max_uses ->
            {:error, "This promo code has reached its usage limit."}

          true ->
            {:ok, promo}
        end
    end
  end

  def validate_code(_), do: {:error, "Please enter a promo code."}

  @doc """
  Calculate discount amount in UGX from a promo and subtotal.
  """
  def calc_discount(%PromoCode{discount_percent: pct}, subtotal) when is_integer(subtotal) do
    round(subtotal * pct / 100)
  end

  def calc_discount(_, _), do: 0

  # ── Usage tracking ────────────────────────────────────────────────────────

  @doc """
  Increments the usage_count for the promo code with the given code string.
  Safe to call async — ignores if code not found.
  """
  def record_usage(code) when is_binary(code) and code != "" do
    case get_promo_code_by_code(code) do
      nil -> :ok
      promo ->
        promo
        |> PromoCode.increment_usage_changeset()
        |> Repo.update()
        :ok
    end
  end

  def record_usage(_), do: :ok

  # ── Analytics ─────────────────────────────────────────────────────────────

  @doc """
  Returns orders that were placed using a specific promo code.
  """
  def list_orders_for_code(code) when is_binary(code) do
    Sheglow.Orders.Order
    |> where([o], o.promo_code == ^String.upcase(String.trim(code)))
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
  end

  @doc """
  Total revenue generated through a promo code (paid orders only).
  """
  def revenue_for_code(code) when is_binary(code) do
    Sheglow.Orders.Order
    |> where([o], o.promo_code == ^String.upcase(String.trim(code)) and o.status in ["paid", "processing", "shipped", "delivered"])
    |> Repo.aggregate(:sum, :total_amount)
    |> then(&(&1 || 0))
  end
end
