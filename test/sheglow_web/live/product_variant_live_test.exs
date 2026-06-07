defmodule SheglowWeb.ProductVariantLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.ProductVariantsFixtures

  @create_attrs %{size: "some size", color_name: "some color_name", color_hex: "some color_hex", stock_quantity: "some stock_quantity"}
  @update_attrs %{size: "some updated size", color_name: "some updated color_name", color_hex: "some updated color_hex", stock_quantity: "some updated stock_quantity"}
  @invalid_attrs %{size: nil, color_name: nil, color_hex: nil, stock_quantity: nil}

  defp create_product_variant(_) do
    product_variant = product_variant_fixture()
    %{product_variant: product_variant}
  end

  describe "Index" do
    setup [:create_product_variant]

    test "lists all product_variants", %{conn: conn, product_variant: product_variant} do
      {:ok, _index_live, html} = live(conn, ~p"/product_variants")

      assert html =~ "Listing Product variants"
      assert html =~ product_variant.size
    end

    test "saves new product_variant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/product_variants")

      assert index_live |> element("a", "New Product variant") |> render_click() =~
               "New Product variant"

      assert_patch(index_live, ~p"/product_variants/new")

      assert index_live
             |> form("#product_variant-form", product_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product_variant-form", product_variant: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/product_variants")

      html = render(index_live)
      assert html =~ "Product variant created successfully"
      assert html =~ "some size"
    end

    test "updates product_variant in listing", %{conn: conn, product_variant: product_variant} do
      {:ok, index_live, _html} = live(conn, ~p"/product_variants")

      assert index_live |> element("#product_variants-#{product_variant.id} a", "Edit") |> render_click() =~
               "Edit Product variant"

      assert_patch(index_live, ~p"/product_variants/#{product_variant}/edit")

      assert index_live
             |> form("#product_variant-form", product_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product_variant-form", product_variant: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/product_variants")

      html = render(index_live)
      assert html =~ "Product variant updated successfully"
      assert html =~ "some updated size"
    end

    test "deletes product_variant in listing", %{conn: conn, product_variant: product_variant} do
      {:ok, index_live, _html} = live(conn, ~p"/product_variants")

      assert index_live |> element("#product_variants-#{product_variant.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#product_variants-#{product_variant.id}")
    end
  end

  describe "Show" do
    setup [:create_product_variant]

    test "displays product_variant", %{conn: conn, product_variant: product_variant} do
      {:ok, _show_live, html} = live(conn, ~p"/product_variants/#{product_variant}")

      assert html =~ "Show Product variant"
      assert html =~ product_variant.size
    end

    test "updates product_variant within modal", %{conn: conn, product_variant: product_variant} do
      {:ok, show_live, _html} = live(conn, ~p"/product_variants/#{product_variant}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product variant"

      assert_patch(show_live, ~p"/product_variants/#{product_variant}/show/edit")

      assert show_live
             |> form("#product_variant-form", product_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#product_variant-form", product_variant: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/product_variants/#{product_variant}")

      html = render(show_live)
      assert html =~ "Product variant updated successfully"
      assert html =~ "some updated size"
    end
  end
end
