defmodule Sheglow.BundlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.Bundles` context.
  """

  @doc """
  Generate a bundle.
  """
  def bundle_fixture(attrs \\ %{}) do
    {:ok, bundle} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        title: "some title"
      })
      |> Sheglow.Bundles.create_bundle()

    bundle
  end
end
