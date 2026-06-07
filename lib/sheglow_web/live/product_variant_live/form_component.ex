defmodule SheglowWeb.ProductVariantLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.ProductVariants

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage product_variant records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product_variant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:color_name]} type="text" label="Color name" />
        <.input field={@form[:color_hex]} type="text" label="Color hex" />
        <.input field={@form[:size]} type="text" label="Size" />
        <.input field={@form[:stock_quantity]} type="text" label="Stock quantity" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Product variant</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product_variant: product_variant} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(ProductVariants.change_product_variant(product_variant))
     end)}
  end

  @impl true
  def handle_event("validate", %{"product_variant" => product_variant_params}, socket) do
    changeset = ProductVariants.change_product_variant(socket.assigns.product_variant, product_variant_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product_variant" => product_variant_params}, socket) do
    save_product_variant(socket, socket.assigns.action, product_variant_params)
  end

  defp save_product_variant(socket, :edit, product_variant_params) do
    case ProductVariants.update_product_variant(socket.assigns.product_variant, product_variant_params) do
      {:ok, product_variant} ->
        notify_parent({:saved, product_variant})

        {:noreply,
         socket
         |> put_flash(:info, "Product variant updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product_variant(socket, :new, product_variant_params) do
    case ProductVariants.create_product_variant(product_variant_params) do
      {:ok, product_variant} ->
        notify_parent({:saved, product_variant})

        {:noreply,
         socket
         |> put_flash(:info, "Product variant created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
