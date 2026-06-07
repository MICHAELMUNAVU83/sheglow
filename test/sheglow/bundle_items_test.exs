defmodule Sheglow.BundleItemsTest do
  use Sheglow.DataCase

  alias Sheglow.BundleItems

  describe "bundle_items" do
    alias Sheglow.BundleItems.BundleItem

    import Sheglow.BundleItemsFixtures

    @invalid_attrs %{}

    test "list_bundle_items/0 returns all bundle_items" do
      bundle_item = bundle_item_fixture()
      assert BundleItems.list_bundle_items() == [bundle_item]
    end

    test "get_bundle_item!/1 returns the bundle_item with given id" do
      bundle_item = bundle_item_fixture()
      assert BundleItems.get_bundle_item!(bundle_item.id) == bundle_item
    end

    test "create_bundle_item/1 with valid data creates a bundle_item" do
      valid_attrs = %{}

      assert {:ok, %BundleItem{} = bundle_item} = BundleItems.create_bundle_item(valid_attrs)
    end

    test "create_bundle_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BundleItems.create_bundle_item(@invalid_attrs)
    end

    test "update_bundle_item/2 with valid data updates the bundle_item" do
      bundle_item = bundle_item_fixture()
      update_attrs = %{}

      assert {:ok, %BundleItem{} = bundle_item} = BundleItems.update_bundle_item(bundle_item, update_attrs)
    end

    test "update_bundle_item/2 with invalid data returns error changeset" do
      bundle_item = bundle_item_fixture()
      assert {:error, %Ecto.Changeset{}} = BundleItems.update_bundle_item(bundle_item, @invalid_attrs)
      assert bundle_item == BundleItems.get_bundle_item!(bundle_item.id)
    end

    test "delete_bundle_item/1 deletes the bundle_item" do
      bundle_item = bundle_item_fixture()
      assert {:ok, %BundleItem{}} = BundleItems.delete_bundle_item(bundle_item)
      assert_raise Ecto.NoResultsError, fn -> BundleItems.get_bundle_item!(bundle_item.id) end
    end

    test "change_bundle_item/1 returns a bundle_item changeset" do
      bundle_item = bundle_item_fixture()
      assert %Ecto.Changeset{} = BundleItems.change_bundle_item(bundle_item)
    end
  end
end
