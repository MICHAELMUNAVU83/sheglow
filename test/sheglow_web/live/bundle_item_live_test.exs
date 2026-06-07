defmodule SheglowWeb.BundleItemLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.BundleItemsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_bundle_item(_) do
    bundle_item = bundle_item_fixture()
    %{bundle_item: bundle_item}
  end

  describe "Index" do
    setup [:create_bundle_item]

    test "lists all bundle_items", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/bundle_items")

      assert html =~ "Listing Bundle items"
    end

    test "saves new bundle_item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bundle_items")

      assert index_live |> element("a", "New Bundle item") |> render_click() =~
               "New Bundle item"

      assert_patch(index_live, ~p"/bundle_items/new")

      assert index_live
             |> form("#bundle_item-form", bundle_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bundle_item-form", bundle_item: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bundle_items")

      html = render(index_live)
      assert html =~ "Bundle item created successfully"
    end

    test "updates bundle_item in listing", %{conn: conn, bundle_item: bundle_item} do
      {:ok, index_live, _html} = live(conn, ~p"/bundle_items")

      assert index_live |> element("#bundle_items-#{bundle_item.id} a", "Edit") |> render_click() =~
               "Edit Bundle item"

      assert_patch(index_live, ~p"/bundle_items/#{bundle_item}/edit")

      assert index_live
             |> form("#bundle_item-form", bundle_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bundle_item-form", bundle_item: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bundle_items")

      html = render(index_live)
      assert html =~ "Bundle item updated successfully"
    end

    test "deletes bundle_item in listing", %{conn: conn, bundle_item: bundle_item} do
      {:ok, index_live, _html} = live(conn, ~p"/bundle_items")

      assert index_live |> element("#bundle_items-#{bundle_item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bundle_items-#{bundle_item.id}")
    end
  end

  describe "Show" do
    setup [:create_bundle_item]

    test "displays bundle_item", %{conn: conn, bundle_item: bundle_item} do
      {:ok, _show_live, html} = live(conn, ~p"/bundle_items/#{bundle_item}")

      assert html =~ "Show Bundle item"
    end

    test "updates bundle_item within modal", %{conn: conn, bundle_item: bundle_item} do
      {:ok, show_live, _html} = live(conn, ~p"/bundle_items/#{bundle_item}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Bundle item"

      assert_patch(show_live, ~p"/bundle_items/#{bundle_item}/show/edit")

      assert show_live
             |> form("#bundle_item-form", bundle_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#bundle_item-form", bundle_item: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bundle_items/#{bundle_item}")

      html = render(show_live)
      assert html =~ "Bundle item updated successfully"
    end
  end
end
