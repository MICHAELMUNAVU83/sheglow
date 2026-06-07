defmodule Sheglow.ProductImages.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field :position, :string
    field :image, :string
    belongs_to :product, Sheglow.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product_image, attrs) do
    product_image
    |> cast(attrs, [:image, :position, :product_id])
    |> validate_required([:image, :position, :product_id])
  end
end
