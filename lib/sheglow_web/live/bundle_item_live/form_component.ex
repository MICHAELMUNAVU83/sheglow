defmodule SheglowWeb.BundleItemLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.BundleItems

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage bundle_item records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="bundle_item-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Bundle item</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{bundle_item: bundle_item} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(BundleItems.change_bundle_item(bundle_item))
     end)}
  end

  @impl true
  def handle_event("validate", %{"bundle_item" => bundle_item_params}, socket) do
    changeset = BundleItems.change_bundle_item(socket.assigns.bundle_item, bundle_item_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bundle_item" => bundle_item_params}, socket) do
    save_bundle_item(socket, socket.assigns.action, bundle_item_params)
  end

  defp save_bundle_item(socket, :edit, bundle_item_params) do
    case BundleItems.update_bundle_item(socket.assigns.bundle_item, bundle_item_params) do
      {:ok, bundle_item} ->
        notify_parent({:saved, bundle_item})

        {:noreply,
         socket
         |> put_flash(:info, "Bundle item updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bundle_item(socket, :new, bundle_item_params) do
    case BundleItems.create_bundle_item(bundle_item_params) do
      {:ok, bundle_item} ->
        notify_parent({:saved, bundle_item})

        {:noreply,
         socket
         |> put_flash(:info, "Bundle item created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
