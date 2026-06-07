defmodule Sheglow.ProductVariants do
  @moduledoc """
  The ProductVariants context.
  """

  import Ecto.Query, warn: false
  alias Sheglow.Repo

  alias Sheglow.ProductVariants.ProductVariant

  @doc """
  Returns the list of product_variants.

  ## Examples

      iex> list_product_variants()
      [%ProductVariant{}, ...]

  """
  def list_product_variants do
    Repo.all(ProductVariant)
  end

  def list_product_variants_for_product(product_id) do
    from(pv in ProductVariant, where: pv.product_id == ^product_id)
    |> Repo.all()
  end

  @doc "Returns a map of %{product_id => [%ProductVariant{}]} for a list of product IDs (one query)."
  def list_variants_for_products([]), do: %{}

  def list_variants_for_products(product_ids) do
    from(pv in ProductVariant, where: pv.product_id in ^product_ids, order_by: [pv.product_id, pv.color_name, pv.size])
    |> Repo.all()
    |> Enum.group_by(& &1.product_id)
  end

  @doc """
  Gets a single product_variant.

  Raises `Ecto.NoResultsError` if the Product variant does not exist.

  ## Examples

      iex> get_product_variant!(123)
      %ProductVariant{}

      iex> get_product_variant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product_variant!(id), do: Repo.get!(ProductVariant, id)

  @doc """
  Creates a product_variant.

  ## Examples

      iex> create_product_variant(%{field: value})
      {:ok, %ProductVariant{}}

      iex> create_product_variant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product_variant(attrs \\ %{}) do
    %ProductVariant{}
    |> ProductVariant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product_variant.

  ## Examples

      iex> update_product_variant(product_variant, %{field: new_value})
      {:ok, %ProductVariant{}}

      iex> update_product_variant(product_variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product_variant(%ProductVariant{} = product_variant, attrs) do
    product_variant
    |> ProductVariant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product_variant.

  ## Examples

      iex> delete_product_variant(product_variant)
      {:ok, %ProductVariant{}}

      iex> delete_product_variant(product_variant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product_variant(%ProductVariant{} = product_variant) do
    Repo.delete(product_variant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product_variant changes.

  ## Examples

      iex> change_product_variant(product_variant)
      %Ecto.Changeset{data: %ProductVariant{}}

  """
  def change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{}) do
    ProductVariant.changeset(product_variant, attrs)
  end
end
