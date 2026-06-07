defmodule Sheglow.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :reference,       :string
    field :email,           :string
    field :name,            :string
    field :phone,           :string
    field :address,         :string
    field :total_amount,    :integer, default: 0
    field :status,          :string,  default: "pending"
    field :items,           {:array, :map}, default: []
    field :promo_code,      :string
    field :discount_amount, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :reference, :email, :name, :phone, :address,
      :total_amount, :status, :items, :promo_code, :discount_amount
    ])
    |> validate_required([:reference, :email, :name, :total_amount])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_inclusion(:status, [
      "pending",
      "paid",
      "processing",
      "shipped",
      "delivered",
      "cancelled",
      "failed"
    ])
    |> unique_constraint(:reference)
  end
end
