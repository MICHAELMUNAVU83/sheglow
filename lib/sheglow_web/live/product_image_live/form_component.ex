defmodule SheglowWeb.ProductImageLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.ProductImages

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage product_image records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product_image-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:image]} type="text" label="Image" />
        <.input field={@form[:position]} type="text" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Product image</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product_image: product_image} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(ProductImages.change_product_image(product_image))
     end)}
  end

  @impl true
  def handle_event("validate", %{"product_image" => product_image_params}, socket) do
    changeset = ProductImages.change_product_image(socket.assigns.product_image, product_image_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product_image" => product_image_params}, socket) do
    save_product_image(socket, socket.assigns.action, product_image_params)
  end

  defp save_product_image(socket, :edit, product_image_params) do
    case ProductImages.update_product_image(socket.assigns.product_image, product_image_params) do
      {:ok, product_image} ->
        notify_parent({:saved, product_image})

        {:noreply,
         socket
         |> put_flash(:info, "Product image updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product_image(socket, :new, product_image_params) do
    case ProductImages.create_product_image(product_image_params) do
      {:ok, product_image} ->
        notify_parent({:saved, product_image})

        {:noreply,
         socket
         |> put_flash(:info, "Product image created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
