defmodule Sheglow.ProductImagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.ProductImages` context.
  """

  @doc """
  Generate a product_image.
  """
  def product_image_fixture(attrs \\ %{}) do
    {:ok, product_image} =
      attrs
      |> Enum.into(%{
        image: "some image",
        position: "some position"
      })
      |> Sheglow.ProductImages.create_product_image()

    product_image
  end
end
