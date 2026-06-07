defmodule SheglowWeb.ProductVariantLive.Show do
  use SheglowWeb, :live_view

  alias Sheglow.ProductVariants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product_variant, ProductVariants.get_product_variant!(id))}
  end

  defp page_title(:show), do: "Show Product variant"
  defp page_title(:edit), do: "Edit Product variant"
end
