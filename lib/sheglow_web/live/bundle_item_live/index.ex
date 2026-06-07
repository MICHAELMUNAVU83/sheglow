defmodule SheglowWeb.BundleItemLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.BundleItems
  alias Sheglow.BundleItems.BundleItem

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bundle_items, BundleItems.list_bundle_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bundle item")
    |> assign(:bundle_item, BundleItems.get_bundle_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bundle item")
    |> assign(:bundle_item, %BundleItem{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bundle items")
    |> assign(:bundle_item, nil)
  end

  @impl true
  def handle_info({SheglowWeb.BundleItemLive.FormComponent, {:saved, bundle_item}}, socket) do
    {:noreply, stream_insert(socket, :bundle_items, bundle_item)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bundle_item = BundleItems.get_bundle_item!(id)
    {:ok, _} = BundleItems.delete_bundle_item(bundle_item)

    {:noreply, stream_delete(socket, :bundle_items, bundle_item)}
  end
end
