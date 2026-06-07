defmodule SheglowWeb.ProductImageLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.ProductImages
  alias Sheglow.ProductImages.ProductImage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :product_images, ProductImages.list_product_images())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product image")
    |> assign(:product_image, ProductImages.get_product_image!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product image")
    |> assign(:product_image, %ProductImage{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Product images")
    |> assign(:product_image, nil)
  end

  @impl true
  def handle_info({SheglowWeb.ProductImageLive.FormComponent, {:saved, product_image}}, socket) do
    {:noreply, stream_insert(socket, :product_images, product_image)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product_image = ProductImages.get_product_image!(id)
    {:ok, _} = ProductImages.delete_product_image(product_image)

    {:noreply, stream_delete(socket, :product_images, product_image)}
  end
end
