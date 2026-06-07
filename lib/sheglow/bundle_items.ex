defmodule Sheglow.BundleItems do
  @moduledoc """
  The BundleItems context.
  """

  import Ecto.Query, warn: false
  alias Sheglow.Repo

  alias Sheglow.BundleItems.BundleItem

  @doc """
  Returns the list of bundle_items.

  ## Examples

      iex> list_bundle_items()
      [%BundleItem{}, ...]

  """
  def list_bundle_items do
    Repo.all(BundleItem)
  end

  def list_bundle_items_for_bundle(bundle_id) do
    from(bi in BundleItem,
      where: bi.bundle_id == ^bundle_id,
      preload: [:product]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single bundle_item.

  Raises `Ecto.NoResultsError` if the Bundle item does not exist.

  ## Examples

      iex> get_bundle_item!(123)
      %BundleItem{}

      iex> get_bundle_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bundle_item!(id), do: Repo.get!(BundleItem, id)

  @doc """
  Creates a bundle_item.

  ## Examples

      iex> create_bundle_item(%{field: value})
      {:ok, %BundleItem{}}

      iex> create_bundle_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bundle_item(attrs \\ %{}) do
    %BundleItem{}
    |> BundleItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bundle_item.

  ## Examples

      iex> update_bundle_item(bundle_item, %{field: new_value})
      {:ok, %BundleItem{}}

      iex> update_bundle_item(bundle_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bundle_item(%BundleItem{} = bundle_item, attrs) do
    bundle_item
    |> BundleItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bundle_item.

  ## Examples

      iex> delete_bundle_item(bundle_item)
      {:ok, %BundleItem{}}

      iex> delete_bundle_item(bundle_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bundle_item(%BundleItem{} = bundle_item) do
    Repo.delete(bundle_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bundle_item changes.

  ## Examples

      iex> change_bundle_item(bundle_item)
      %Ecto.Changeset{data: %BundleItem{}}

  """
  def change_bundle_item(%BundleItem{} = bundle_item, attrs \\ %{}) do
    BundleItem.changeset(bundle_item, attrs)
  end
end
