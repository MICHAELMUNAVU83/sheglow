defmodule Sheglow.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :email, :string
    field :name, :string
    field :phone, :string
    field :address, :string
    field :order_count, :integer, default: 0
    field :total_spent, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email, :name, :phone, :address, :order_count, :total_spent])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
