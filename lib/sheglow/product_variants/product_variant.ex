defmodule Sheglow.ProductVariants.ProductVariant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_variants" do
    field :size, :string
    field :color_name, :string
    field :color_hex, :string
    field :stock_quantity, :string
    belongs_to :product, Sheglow.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product_variant, attrs) do
    product_variant
    |> cast(attrs, [:color_name, :color_hex, :size, :stock_quantity, :product_id])
    |> validate_required([:color_name, :color_hex, :size, :stock_quantity, :product_id])
  end
end
