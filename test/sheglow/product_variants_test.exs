defmodule Sheglow.ProductVariantsTest do
  use Sheglow.DataCase

  alias Sheglow.ProductVariants

  describe "product_variants" do
    alias Sheglow.ProductVariants.ProductVariant

    import Sheglow.ProductVariantsFixtures

    @invalid_attrs %{size: nil, color_name: nil, color_hex: nil, stock_quantity: nil}

    test "list_product_variants/0 returns all product_variants" do
      product_variant = product_variant_fixture()
      assert ProductVariants.list_product_variants() == [product_variant]
    end

    test "get_product_variant!/1 returns the product_variant with given id" do
      product_variant = product_variant_fixture()
      assert ProductVariants.get_product_variant!(product_variant.id) == product_variant
    end

    test "create_product_variant/1 with valid data creates a product_variant" do
      valid_attrs = %{size: "some size", color_name: "some color_name", color_hex: "some color_hex", stock_quantity: "some stock_quantity"}

      assert {:ok, %ProductVariant{} = product_variant} = ProductVariants.create_product_variant(valid_attrs)
      assert product_variant.size == "some size"
      assert product_variant.color_name == "some color_name"
      assert product_variant.color_hex == "some color_hex"
      assert product_variant.stock_quantity == "some stock_quantity"
    end

    test "create_product_variant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProductVariants.create_product_variant(@invalid_attrs)
    end

    test "update_product_variant/2 with valid data updates the product_variant" do
      product_variant = product_variant_fixture()
      update_attrs = %{size: "some updated size", color_name: "some updated color_name", color_hex: "some updated color_hex", stock_quantity: "some updated stock_quantity"}

      assert {:ok, %ProductVariant{} = product_variant} = ProductVariants.update_product_variant(product_variant, update_attrs)
      assert product_variant.size == "some updated size"
      assert product_variant.color_name == "some updated color_name"
      assert product_variant.color_hex == "some updated color_hex"
      assert product_variant.stock_quantity == "some updated stock_quantity"
    end

    test "update_product_variant/2 with invalid data returns error changeset" do
      product_variant = product_variant_fixture()
      assert {:error, %Ecto.Changeset{}} = ProductVariants.update_product_variant(product_variant, @invalid_attrs)
      assert product_variant == ProductVariants.get_product_variant!(product_variant.id)
    end

    test "delete_product_variant/1 deletes the product_variant" do
      product_variant = product_variant_fixture()
      assert {:ok, %ProductVariant{}} = ProductVariants.delete_product_variant(product_variant)
      assert_raise Ecto.NoResultsError, fn -> ProductVariants.get_product_variant!(product_variant.id) end
    end

    test "change_product_variant/1 returns a product_variant changeset" do
      product_variant = product_variant_fixture()
      assert %Ecto.Changeset{} = ProductVariants.change_product_variant(product_variant)
    end
  end
end
