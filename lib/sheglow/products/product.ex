defmodule Sheglow.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :position, :integer
    field :status, :string
    field :description, :string
    field :slug, :string
    field :image, :string
    field :base_price, :integer
    field :badge_label, :string
    field :badge_color, :string
    field :is_featured, :boolean, default: false
    field :is_bestseller, :boolean, default: false
    field :is_new_arrival, :boolean, default: false
    field :size_advice, :string
    field :shipping_returns, :string
    belongs_to :collection, Sheglow.Collections.Collection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :base_price,
      :badge_label,
      :image,
      :badge_color,
      :is_featured,
      :is_bestseller,
      :is_new_arrival,
      :position,
      :status,
      :collection_id,
      :size_advice,
      :shipping_returns
    ])
    |> validate_required([
      :name,
      :slug,
      :description,
      :image,
      :base_price,
      :is_featured,
      :is_bestseller,
      :is_new_arrival,
      :position,
      :status,
      :collection_id
    ])
  end
end
