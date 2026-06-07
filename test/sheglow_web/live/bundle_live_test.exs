defmodule SheglowWeb.BundleLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.BundlesFixtures

  @create_attrs %{description: "some description", title: "some title", image: "some image"}
  @update_attrs %{description: "some updated description", title: "some updated title", image: "some updated image"}
  @invalid_attrs %{description: nil, title: nil, image: nil}

  defp create_bundle(_) do
    bundle = bundle_fixture()
    %{bundle: bundle}
  end

  describe "Index" do
    setup [:create_bundle]

    test "lists all bundles", %{conn: conn, bundle: bundle} do
      {:ok, _index_live, html} = live(conn, ~p"/bundles")

      assert html =~ "Listing Bundles"
      assert html =~ bundle.description
    end

    test "saves new bundle", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bundles")

      assert index_live |> element("a", "New Bundle") |> render_click() =~
               "New Bundle"

      assert_patch(index_live, ~p"/bundles/new")

      assert index_live
             |> form("#bundle-form", bundle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bundle-form", bundle: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bundles")

      html = render(index_live)
      assert html =~ "Bundle created successfully"
      assert html =~ "some description"
    end

    test "updates bundle in listing", %{conn: conn, bundle: bundle} do
      {:ok, index_live, _html} = live(conn, ~p"/bundles")

      assert index_live |> element("#bundles-#{bundle.id} a", "Edit") |> render_click() =~
               "Edit Bundle"

      assert_patch(index_live, ~p"/bundles/#{bundle}/edit")

      assert index_live
             |> form("#bundle-form", bundle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bundle-form", bundle: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bundles")

      html = render(index_live)
      assert html =~ "Bundle updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes bundle in listing", %{conn: conn, bundle: bundle} do
      {:ok, index_live, _html} = live(conn, ~p"/bundles")

      assert index_live |> element("#bundles-#{bundle.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bundles-#{bundle.id}")
    end
  end

  describe "Show" do
    setup [:create_bundle]

    test "displays bundle", %{conn: conn, bundle: bundle} do
      {:ok, _show_live, html} = live(conn, ~p"/bundles/#{bundle}")

      assert html =~ "Show Bundle"
      assert html =~ bundle.description
    end

    test "updates bundle within modal", %{conn: conn, bundle: bundle} do
      {:ok, show_live, _html} = live(conn, ~p"/bundles/#{bundle}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Bundle"

      assert_patch(show_live, ~p"/bundles/#{bundle}/show/edit")

      assert show_live
             |> form("#bundle-form", bundle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#bundle-form", bundle: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bundles/#{bundle}")

      html = render(show_live)
      assert html =~ "Bundle updated successfully"
      assert html =~ "some updated description"
    end
  end
end
