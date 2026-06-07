defmodule Sheglow.Promotions.PromoCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promo_codes" do
    field :code,             :string
    field :description,      :string
    field :influencer_name,  :string
    field :discount_percent, :integer
    field :is_active,        :boolean, default: true
    field :usage_count,      :integer, default: 0
    field :max_uses,         :integer   # nil = unlimited
    field :expires_at,       :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(promo, attrs) do
    promo
    |> cast(attrs, [
      :code, :description, :influencer_name,
      :discount_percent, :is_active, :max_uses, :expires_at
    ])
    |> validate_required([:code, :discount_percent])
    |> validate_number(:discount_percent, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_length(:code, min: 2, max: 30)
    |> update_change(:code, &(String.upcase(&1) |> String.replace(~r/[^A-Z0-9\-_]/, "")))
    |> validate_format(:code, ~r/^[A-Z0-9\-_]+$/, message: "only letters, numbers, hyphens and underscores")
    |> unique_constraint(:code, message: "that code already exists")
  end

  def increment_usage_changeset(promo) do
    change(promo, usage_count: (promo.usage_count || 0) + 1)
  end
end
