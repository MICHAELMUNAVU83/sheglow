defmodule Sheglow.BundlesTest do
  use Sheglow.DataCase

  alias Sheglow.Bundles

  describe "bundles" do
    alias Sheglow.Bundles.Bundle

    import Sheglow.BundlesFixtures

    @invalid_attrs %{description: nil, title: nil, image: nil}

    test "list_bundles/0 returns all bundles" do
      bundle = bundle_fixture()
      assert Bundles.list_bundles() == [bundle]
    end

    test "get_bundle!/1 returns the bundle with given id" do
      bundle = bundle_fixture()
      assert Bundles.get_bundle!(bundle.id) == bundle
    end

    test "create_bundle/1 with valid data creates a bundle" do
      valid_attrs = %{description: "some description", title: "some title", image: "some image"}

      assert {:ok, %Bundle{} = bundle} = Bundles.create_bundle(valid_attrs)
      assert bundle.description == "some description"
      assert bundle.title == "some title"
      assert bundle.image == "some image"
    end

    test "create_bundle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bundles.create_bundle(@invalid_attrs)
    end

    test "update_bundle/2 with valid data updates the bundle" do
      bundle = bundle_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", image: "some updated image"}

      assert {:ok, %Bundle{} = bundle} = Bundles.update_bundle(bundle, update_attrs)
      assert bundle.description == "some updated description"
      assert bundle.title == "some updated title"
      assert bundle.image == "some updated image"
    end

    test "update_bundle/2 with invalid data returns error changeset" do
      bundle = bundle_fixture()
      assert {:error, %Ecto.Changeset{}} = Bundles.update_bundle(bundle, @invalid_attrs)
      assert bundle == Bundles.get_bundle!(bundle.id)
    end

    test "delete_bundle/1 deletes the bundle" do
      bundle = bundle_fixture()
      assert {:ok, %Bundle{}} = Bundles.delete_bundle(bundle)
      assert_raise Ecto.NoResultsError, fn -> Bundles.get_bundle!(bundle.id) end
    end

    test "change_bundle/1 returns a bundle changeset" do
      bundle = bundle_fixture()
      assert %Ecto.Changeset{} = Bundles.change_bundle(bundle)
    end
  end
end
