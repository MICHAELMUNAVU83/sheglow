defmodule SheglowWeb.ProductImageLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.ProductImagesFixtures

  @create_attrs %{position: "some position", image: "some image"}
  @update_attrs %{position: "some updated position", image: "some updated image"}
  @invalid_attrs %{position: nil, image: nil}

  defp create_product_image(_) do
    product_image = product_image_fixture()
    %{product_image: product_image}
  end

  describe "Index" do
    setup [:create_product_image]

    test "lists all product_images", %{conn: conn, product_image: product_image} do
      {:ok, _index_live, html} = live(conn, ~p"/product_images")

      assert html =~ "Listing Product images"
      assert html =~ product_image.position
    end

    test "saves new product_image", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/product_images")

      assert index_live |> element("a", "New Product image") |> render_click() =~
               "New Product image"

      assert_patch(index_live, ~p"/product_images/new")

      assert index_live
             |> form("#product_image-form", product_image: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product_image-form", product_image: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/product_images")

      html = render(index_live)
      assert html =~ "Product image created successfully"
      assert html =~ "some position"
    end

    test "updates product_image in listing", %{conn: conn, product_image: product_image} do
      {:ok, index_live, _html} = live(conn, ~p"/product_images")

      assert index_live |> element("#product_images-#{product_image.id} a", "Edit") |> render_click() =~
               "Edit Product image"

      assert_patch(index_live, ~p"/product_images/#{product_image}/edit")

      assert index_live
             |> form("#product_image-form", product_image: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product_image-form", product_image: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/product_images")

      html = render(index_live)
      assert html =~ "Product image updated successfully"
      assert html =~ "some updated position"
    end

    test "deletes product_image in listing", %{conn: conn, product_image: product_image} do
      {:ok, index_live, _html} = live(conn, ~p"/product_images")

      assert index_live |> element("#product_images-#{product_image.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#product_images-#{product_image.id}")
    end
  end

  describe "Show" do
    setup [:create_product_image]

    test "displays product_image", %{conn: conn, product_image: product_image} do
      {:ok, _show_live, html} = live(conn, ~p"/product_images/#{product_image}")

      assert html =~ "Show Product image"
      assert html =~ product_image.position
    end

    test "updates product_image within modal", %{conn: conn, product_image: product_image} do
      {:ok, show_live, _html} = live(conn, ~p"/product_images/#{product_image}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product image"

      assert_patch(show_live, ~p"/product_images/#{product_image}/show/edit")

      assert show_live
             |> form("#product_image-form", product_image: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#product_image-form", product_image: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/product_images/#{product_image}")

      html = render(show_live)
      assert html =~ "Product image updated successfully"
      assert html =~ "some updated position"
    end
  end
end
