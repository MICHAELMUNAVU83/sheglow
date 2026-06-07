defmodule Sheglow.BundleItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.BundleItems` context.
  """

  @doc """
  Generate a bundle_item.
  """
  def bundle_item_fixture(attrs \\ %{}) do
    {:ok, bundle_item} =
      attrs
      |> Enum.into(%{

      })
      |> Sheglow.BundleItems.create_bundle_item()

    bundle_item
  end
end
