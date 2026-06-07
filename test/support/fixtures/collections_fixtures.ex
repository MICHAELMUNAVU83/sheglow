defmodule Sheglow.CollectionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.Collections` context.
  """

  @doc """
  Generate a collection.
  """
  def collection_fixture(attrs \\ %{}) do
    {:ok, collection} =
      attrs
      |> Enum.into(%{
        is_active: true,
        position: 42,
        slug: "some slug",
        title: "some title"
      })
      |> Sheglow.Collections.create_collection()

    collection
  end
end
