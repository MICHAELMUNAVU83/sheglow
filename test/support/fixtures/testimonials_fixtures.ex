defmodule Sheglow.TestimonialsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sheglow.Testimonials` context.
  """

  @doc """
  Generate a testimonial.
  """
  def testimonial_fixture(attrs \\ %{}) do
    {:ok, testimonial} =
      attrs
      |> Enum.into(%{
        body: "some body",
        image: "some image",
        is_active: true,
        name: "some name",
        position: 42,
        rating: 42
      })
      |> Sheglow.Testimonials.create_testimonial()

    testimonial
  end
end
