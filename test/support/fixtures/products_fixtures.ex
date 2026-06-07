defmodule Sheglow.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        badge_color: "some badge_color",
        badge_label: "some badge_label",
        base_price: 42,
        description: "some description",
        is_bestseller: true,
        is_featured: true,
        is_new_arrival: true,
        name: "some name",
        position: 42,
        slug: "some slug",
        status: "some status"
      })
      |> Sheglow.Products.create_product()

    product
  end
end
