defmodule Sheglow.BundleItems.BundleItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bundle_items" do
    belongs_to :bundle, Sheglow.Bundles.Bundle
    belongs_to :product, Sheglow.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bundle_item, attrs) do
    bundle_item
    |> cast(attrs, [:bundle_id, :product_id])
    |> validate_required([:bundle_id, :product_id])
    |> unique_constraint([:bundle_id, :product_id])
  end
end
