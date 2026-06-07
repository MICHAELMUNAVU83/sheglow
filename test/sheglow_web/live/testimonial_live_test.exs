defmodule SheglowWeb.TestimonialLiveTest do
  use SheglowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sheglow.TestimonialsFixtures

  @create_attrs %{name: "some name", position: 42, image: "some image", body: "some body", rating: 42, is_active: true}
  @update_attrs %{name: "some updated name", position: 43, image: "some updated image", body: "some updated body", rating: 43, is_active: false}
  @invalid_attrs %{name: nil, position: nil, image: nil, body: nil, rating: nil, is_active: false}

  defp create_testimonial(_) do
    testimonial = testimonial_fixture()
    %{testimonial: testimonial}
  end

  describe "Index" do
    setup [:create_testimonial]

    test "lists all testimonials", %{conn: conn, testimonial: testimonial} do
      {:ok, _index_live, html} = live(conn, ~p"/testimonials")

      assert html =~ "Listing Testimonials"
      assert html =~ testimonial.name
    end

    test "saves new testimonial", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/testimonials")

      assert index_live |> element("a", "New Testimonial") |> render_click() =~
               "New Testimonial"

      assert_patch(index_live, ~p"/testimonials/new")

      assert index_live
             |> form("#testimonial-form", testimonial: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#testimonial-form", testimonial: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/testimonials")

      html = render(index_live)
      assert html =~ "Testimonial created successfully"
      assert html =~ "some name"
    end

    test "updates testimonial in listing", %{conn: conn, testimonial: testimonial} do
      {:ok, index_live, _html} = live(conn, ~p"/testimonials")

      assert index_live |> element("#testimonials-#{testimonial.id} a", "Edit") |> render_click() =~
               "Edit Testimonial"

      assert_patch(index_live, ~p"/testimonials/#{testimonial}/edit")

      assert index_live
             |> form("#testimonial-form", testimonial: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#testimonial-form", testimonial: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/testimonials")

      html = render(index_live)
      assert html =~ "Testimonial updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes testimonial in listing", %{conn: conn, testimonial: testimonial} do
      {:ok, index_live, _html} = live(conn, ~p"/testimonials")

      assert index_live |> element("#testimonials-#{testimonial.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#testimonials-#{testimonial.id}")
    end
  end

  describe "Show" do
    setup [:create_testimonial]

    test "displays testimonial", %{conn: conn, testimonial: testimonial} do
      {:ok, _show_live, html} = live(conn, ~p"/testimonials/#{testimonial}")

      assert html =~ "Show Testimonial"
      assert html =~ testimonial.name
    end

    test "updates testimonial within modal", %{conn: conn, testimonial: testimonial} do
      {:ok, show_live, _html} = live(conn, ~p"/testimonials/#{testimonial}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Testimonial"

      assert_patch(show_live, ~p"/testimonials/#{testimonial}/show/edit")

      assert show_live
             |> form("#testimonial-form", testimonial: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#testimonial-form", testimonial: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/testimonials/#{testimonial}")

      html = render(show_live)
      assert html =~ "Testimonial updated successfully"
      assert html =~ "some updated name"
    end
  end
end
