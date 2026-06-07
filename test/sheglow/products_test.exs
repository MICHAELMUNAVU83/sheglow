defmodule Sheglow.ProductsTest do
  use Sheglow.DataCase

  alias Sheglow.Products

  describe "products" do
    alias Sheglow.Products.Product

    import Sheglow.ProductsFixtures

    @invalid_attrs %{name: nil, position: nil, status: nil, description: nil, slug: nil, base_price: nil, badge_label: nil, badge_color: nil, is_featured: nil, is_bestseller: nil, is_new_arrival: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", position: 42, status: "some status", description: "some description", slug: "some slug", base_price: 42, badge_label: "some badge_label", badge_color: "some badge_color", is_featured: true, is_bestseller: true, is_new_arrival: true}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.position == 42
      assert product.status == "some status"
      assert product.description == "some description"
      assert product.slug == "some slug"
      assert product.base_price == 42
      assert product.badge_label == "some badge_label"
      assert product.badge_color == "some badge_color"
      assert product.is_featured == true
      assert product.is_bestseller == true
      assert product.is_new_arrival == true
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", position: 43, status: "some updated status", description: "some updated description", slug: "some updated slug", base_price: 43, badge_label: "some updated badge_label", badge_color: "some updated badge_color", is_featured: false, is_bestseller: false, is_new_arrival: false}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.position == 43
      assert product.status == "some updated status"
      assert product.description == "some updated description"
      assert product.slug == "some updated slug"
      assert product.base_price == 43
      assert product.badge_label == "some updated badge_label"
      assert product.badge_color == "some updated badge_color"
      assert product.is_featured == false
      assert product.is_bestseller == false
      assert product.is_new_arrival == false
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
