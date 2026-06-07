defmodule Sheglow.ProductVariantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.ProductVariants` context.
  """

  @doc """
  Generate a product_variant.
  """
  def product_variant_fixture(attrs \\ %{}) do
    {:ok, product_variant} =
      attrs
      |> Enum.into(%{
        color_hex: "some color_hex",
        color_name: "some color_name",
        size: "some size",
        stock_quantity: "some stock_quantity"
      })
      |> Sheglow.ProductVariants.create_product_variant()

    product_variant
  end
end
