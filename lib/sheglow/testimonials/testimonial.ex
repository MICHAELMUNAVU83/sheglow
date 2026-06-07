defmodule Sheglow.Testimonials.Testimonial do
  use Ecto.Schema
  import Ecto.Changeset

  schema "testimonials" do
    field :name, :string
    field :position, :integer
    field :image, :string
    field :body, :string
    field :rating, :integer
    field :is_active, :boolean, default: false
    belongs_to :product, Sheglow.Products.Product
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(testimonial, attrs) do
    testimonial
    |> cast(attrs, [:name, :rating, :image, :body, :is_active, :position, :product_id])
    |> validate_required([:name, :rating, :image, :body, :is_active, :position])
  end
end
