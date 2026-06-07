defmodule Sheglow.TestimonialsTest do
  use Sheglow.DataCase

  alias Sheglow.Testimonials

  describe "testimonials" do
    alias Sheglow.Testimonials.Testimonial

    import Sheglow.TestimonialsFixtures

    @invalid_attrs %{name: nil, position: nil, image: nil, body: nil, rating: nil, is_active: nil}

    test "list_testimonials/0 returns all testimonials" do
      testimonial = testimonial_fixture()
      assert Testimonials.list_testimonials() == [testimonial]
    end

    test "get_testimonial!/1 returns the testimonial with given id" do
      testimonial = testimonial_fixture()
      assert Testimonials.get_testimonial!(testimonial.id) == testimonial
    end

    test "create_testimonial/1 with valid data creates a testimonial" do
      valid_attrs = %{name: "some name", position: 42, image: "some image", body: "some body", rating: 42, is_active: true}

      assert {:ok, %Testimonial{} = testimonial} = Testimonials.create_testimonial(valid_attrs)
      assert testimonial.name == "some name"
      assert testimonial.position == 42
      assert testimonial.image == "some image"
      assert testimonial.body == "some body"
      assert testimonial.rating == 42
      assert testimonial.is_active == true
    end

    test "create_testimonial/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Testimonials.create_testimonial(@invalid_attrs)
    end

    test "update_testimonial/2 with valid data updates the testimonial" do
      testimonial = testimonial_fixture()
      update_attrs = %{name: "some updated name", position: 43, image: "some updated image", body: "some updated body", rating: 43, is_active: false}

      assert {:ok, %Testimonial{} = testimonial} = Testimonials.update_testimonial(testimonial, update_attrs)
      assert testimonial.name == "some updated name"
      assert testimonial.position == 43
      assert testimonial.image == "some updated image"
      assert testimonial.body == "some updated body"
      assert testimonial.rating == 43
      assert testimonial.is_active == false
    end

    test "update_testimonial/2 with invalid data returns error changeset" do
      testimonial = testimonial_fixture()
      assert {:error, %Ecto.Changeset{}} = Testimonials.update_testimonial(testimonial, @invalid_attrs)
      assert testimonial == Testimonials.get_testimonial!(testimonial.id)
    end

    test "delete_testimonial/1 deletes the testimonial" do
      testimonial = testimonial_fixture()
      assert {:ok, %Testimonial{}} = Testimonials.delete_testimonial(testimonial)
      assert_raise Ecto.NoResultsError, fn -> Testimonials.get_testimonial!(testimonial.id) end
    end

    test "change_testimonial/1 returns a testimonial changeset" do
      testimonial = testimonial_fixture()
      assert %Ecto.Changeset{} = Testimonials.change_testimonial(testimonial)
    end
  end
end
