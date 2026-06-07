defmodule SheglowWeb.ProductVariantLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.ProductVariants
  alias Sheglow.ProductVariants.ProductVariant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :product_variants, ProductVariants.list_product_variants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product variant")
    |> assign(:product_variant, ProductVariants.get_product_variant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product variant")
    |> assign(:product_variant, %ProductVariant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Product variants")
    |> assign(:product_variant, nil)
  end

  @impl true
  def handle_info({SheglowWeb.ProductVariantLive.FormComponent, {:saved, product_variant}}, socket) do
    {:noreply, stream_insert(socket, :product_variants, product_variant)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product_variant = ProductVariants.get_product_variant!(id)
    {:ok, _} = ProductVariants.delete_product_variant(product_variant)

    {:noreply, stream_delete(socket, :product_variants, product_variant)}
  end
end
