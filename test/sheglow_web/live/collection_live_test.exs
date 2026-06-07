defmodule SheglowWeb.CollectionLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.CollectionsFixtures

  @create_attrs %{position: 42, title: "some title", slug: "some slug", is_active: true}
  @update_attrs %{position: 43, title: "some updated title", slug: "some updated slug", is_active: false}
  @invalid_attrs %{position: nil, title: nil, slug: nil, is_active: false}

  defp create_collection(_) do
    collection = collection_fixture()
    %{collection: collection}
  end

  describe "Index" do
    setup [:create_collection]

    test "lists all collections", %{conn: conn, collection: collection} do
      {:ok, _index_live, html} = live(conn, ~p"/collections")

      assert html =~ "Listing Collections"
      assert html =~ collection.title
    end

    test "saves new collection", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/collections")

      assert index_live |> element("a", "New Collection") |> render_click() =~
               "New Collection"

      assert_patch(index_live, ~p"/collections/new")

      assert index_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#collection-form", collection: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/collections")

      html = render(index_live)
      assert html =~ "Collection created successfully"
      assert html =~ "some title"
    end

    test "updates collection in listing", %{conn: conn, collection: collection} do
      {:ok, index_live, _html} = live(conn, ~p"/collections")

      assert index_live |> element("#collections-#{collection.id} a", "Edit") |> render_click() =~
               "Edit Collection"

      assert_patch(index_live, ~p"/collections/#{collection}/edit")

      assert index_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#collection-form", collection: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/collections")

      html = render(index_live)
      assert html =~ "Collection updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes collection in listing", %{conn: conn, collection: collection} do
      {:ok, index_live, _html} = live(conn, ~p"/collections")

      assert index_live |> element("#collections-#{collection.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#collections-#{collection.id}")
    end
  end

  describe "Show" do
    setup [:create_collection]

    test "displays collection", %{conn: conn, collection: collection} do
      {:ok, _show_live, html} = live(conn, ~p"/collections/#{collection}")

      assert html =~ "Show Collection"
      assert html =~ collection.title
    end

    test "updates collection within modal", %{conn: conn, collection: collection} do
      {:ok, show_live, _html} = live(conn, ~p"/collections/#{collection}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Collection"

      assert_patch(show_live, ~p"/collections/#{collection}/show/edit")

      assert show_live
             |> form("#collection-form", collection: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#collection-form", collection: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/collections/#{collection}")

      html = render(show_live)
      assert html =~ "Collection updated successfully"
      assert html =~ "some updated title"
    end
  end
end
