defmodule SheglowWeb.ProductLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Products
  alias Sheglow.ProductImages
  alias Sheglow.ProductVariants
  alias Sheglow.ProductVariants.ProductVariant
  alias Sheglow.Collections
  alias Sheglow.Orders

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Product")
     |> assign(:current_path, "/admin/products")
     |> assign(:show_variant_form, false)
     |> assign(:variant_form, to_form(ProductVariants.change_product_variant(%ProductVariant{})))
     |> assign(:editing_variant_id, nil)
     |> assign(:editing_variant, nil)
     |> assign(:edit_variant_form, nil)
     |> allow_upload(:product_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 10,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Products.get_product!(id)

    {:noreply,
     socket
     |> assign(:page_title, product.name)
     |> assign(:product, product)
     |> assign(:collection, load_collection(product.collection_id))
     |> assign(:images, ProductImages.list_product_images_for_product(id))
     |> assign(:variants, ProductVariants.list_product_variants_for_product(id))
     |> assign(:order_count, Orders.count_orders_for_product(product.id))}
  end

  @impl true
  def handle_info({SheglowWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply,
     socket
     |> assign(:product, product)
     |> assign(:collection, load_collection(product.collection_id))}
  end

  # ── Images ────────────────────────────────────────────────────────

  @impl true
  def handle_event("noop", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("upload_images", _params, socket) do
    product = socket.assigns.product

    next_position =
      case socket.assigns.images do
        [] -> 1
        imgs -> (imgs |> Enum.map(fn i -> String.to_integer(i.position) end) |> Enum.max()) + 1
      end

    uploaded =
      consume_uploaded_entries(socket, :product_image, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:sheglow),
            "static",
            "uploads",
            Path.basename(path)
          ])

        File.cp!(path, dest)
        {:ok, "/uploads/" <> Path.basename(dest)}
      end)

    Enum.with_index(uploaded, next_position)
    |> Enum.each(fn {url, pos} ->
      ProductImages.create_product_image(%{
        image: url,
        position: Integer.to_string(pos),
        product_id: product.id
      })
    end)

    {:noreply, assign(socket, :images, ProductImages.list_product_images_for_product(product.id))}
  end

  @impl true
  def handle_event("cancel_image_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image, ref)}
  end

  @impl true
  def handle_event("delete_image", %{"id" => id}, socket) do
    image = ProductImages.get_product_image!(id)
    {:ok, _} = ProductImages.delete_product_image(image)

    {:noreply,
     assign(
       socket,
       :images,
       ProductImages.list_product_images_for_product(socket.assigns.product.id)
     )}
  end

  # ── Variants ──────────────────────────────────────────────────────

  @impl true
  def handle_event("toggle_variant_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_variant_form, !socket.assigns.show_variant_form)
     |> assign(:editing_variant_id, nil)
     |> assign(:editing_variant, nil)
     |> assign(:edit_variant_form, nil)}
  end

  @impl true
  def handle_event("validate_variant", %{"product_variant" => params}, socket) do
    changeset =
      %ProductVariant{}
      |> ProductVariants.change_product_variant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :variant_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save_variant", %{"product_variant" => params}, socket) do
    params = Map.put(params, "product_id", socket.assigns.product.id)

    case ProductVariants.create_product_variant(params) do
      {:ok, _variant} ->
        {:noreply,
         socket
         |> assign(
           :variants,
           ProductVariants.list_product_variants_for_product(socket.assigns.product.id)
         )
         |> assign(:show_variant_form, false)
         |> assign(
           :variant_form,
           to_form(ProductVariants.change_product_variant(%ProductVariant{}))
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, :variant_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("delete_variant", %{"id" => id}, socket) do
    variant = ProductVariants.get_product_variant!(id)
    {:ok, _} = ProductVariants.delete_product_variant(variant)

    {:noreply,
     assign(
       socket,
       :variants,
       ProductVariants.list_product_variants_for_product(socket.assigns.product.id)
     )}
  end

  @impl true
  def handle_event("edit_variant", %{"id" => id}, socket) do
    variant = ProductVariants.get_product_variant!(id)
    changeset = ProductVariants.change_product_variant(variant)

    {:noreply,
     socket
     |> assign(:editing_variant_id, variant.id)
     |> assign(:editing_variant, variant)
     |> assign(:edit_variant_form, to_form(changeset))
     |> assign(:show_variant_form, false)}
  end

  @impl true
  def handle_event("cancel_edit_variant", _, socket) do
    {:noreply,
     socket
     |> assign(:editing_variant_id, nil)
     |> assign(:editing_variant, nil)
     |> assign(:edit_variant_form, nil)}
  end

  @impl true
  def handle_event("validate_edit_variant", %{"product_variant" => params}, socket) do
    changeset =
      socket.assigns.editing_variant
      |> ProductVariants.change_product_variant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :edit_variant_form, to_form(changeset))}
  end

  @impl true
  def handle_event("update_variant", %{"product_variant" => params}, socket) do
    case ProductVariants.update_product_variant(socket.assigns.editing_variant, params) do
      {:ok, _variant} ->
        {:noreply,
         socket
         |> assign(
           :variants,
           ProductVariants.list_product_variants_for_product(socket.assigns.product.id)
         )
         |> assign(:editing_variant_id, nil)
         |> assign(:editing_variant, nil)
         |> assign(:edit_variant_form, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :edit_variant_form, to_form(changeset))}
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp load_collection(nil), do: nil
  defp load_collection(id), do: Collections.get_collection!(id)

  defp upload_error_to_string(:too_large), do: "File is too large (max 5 MB)"
  defp upload_error_to_string(:not_accepted), do: "Unsupported file type"
  defp upload_error_to_string(:too_many_files), do: "Too many files"
  defp upload_error_to_string(err), do: "Upload error: #{inspect(err)}"

  # ── Render ────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page header --%>
    <div class="mb-8 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/products"}>
          <button class="flex h-10 w-10 items-center justify-center rounded-xl border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
            <svg
              class="h-5 w-5"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
        </.link>
        <div>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Catalogue</p>
          <h1 class="mt-0.5 text-3xl font-bold text-gray-900">{@product.name}</h1>
        </div>
      </div>

      <.link patch={~p"/admin/products/#{@product}/show/edit"}>
        <button class="flex items-center gap-2 rounded-xl bg-gray-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-gray-700">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
          </svg>
          Edit Product
        </button>
      </.link>
    </div>

    <%!-- Top summary card --%>
    <div class="mb-8 overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex gap-8 p-8">
        <%!-- Hero image --%>
        <div class="flex-shrink-0">
          <%= if @product.image && @product.image != "" do %>
            <img
              src={@product.image}
              alt={@product.name}
              class="h-52 w-52 rounded-2xl border border-gray-200 object-cover object-top shadow-sm"
            />
          <% else %>
            <div class="flex h-52 w-52 items-center justify-center rounded-2xl border border-gray-200 bg-gray-50 text-6xl">
              👗
            </div>
          <% end %>
        </div>

        <%!-- Details --%>
        <div class="min-w-0 flex-1 py-1">
          <div class="flex flex-wrap items-start justify-between gap-3">
            <div>
              <div class="flex items-center gap-3">
                <h2 class="text-2xl font-bold text-gray-900">{@product.name}</h2>
                <%= if @product.badge_label not in [nil, ""] do %>
                  <span
                    class="inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold"
                    style={"background-color: #{@product.badge_color || "#f3f4f6"}; color: white"}
                  >
                    {@product.badge_label}
                  </span>
                <% end %>
              </div>
              <code class="mt-1 block text-sm text-gray-400">/products/{@product.slug}</code>
            </div>

            <span class={[
              "inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-xs font-semibold capitalize",
              case @product.status do
                "active" -> "bg-green-50 text-green-700"
                _ -> "bg-gray-100 text-gray-500"
              end
            ]}>
              <span class={[
                "h-2 w-2 rounded-full",
                case @product.status do
                  "active" -> "bg-green-500"
                  _ -> "bg-gray-400"
                end
              ]} />
              {@product.status || "draft"}
            </span>
          </div>

          <p class="mt-4 text-base text-gray-600">{@product.description}</p>

          <div class="mt-6 flex flex-wrap items-center gap-5 text-base">
            <span class="text-xl font-bold text-gray-900">
              UGX {SheglowWeb.Format.price(@product.base_price)}
            </span>

            <%= if @collection do %>
              <span class="flex items-center gap-1.5 text-gray-500">
                <svg
                  class="h-4 w-4"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <polygon points="12 2 2 7 12 12 22 7 12 2" />
                  <polyline points="2 17 12 22 22 17" />
                  <polyline points="2 12 12 17 22 12" />
                </svg>
                <span class="font-medium">{@collection.title}</span>
              </span>
            <% end %>

            <span class="text-gray-400 text-sm">Position {@product.position}</span>

            <.link
              navigate="/admin/orders"
              class="flex items-center gap-1.5 rounded-full bg-gray-900 px-3 py-1 text-xs font-semibold text-white hover:bg-gray-700 transition"
            >
              <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2"
                />
              </svg>
              {@order_count} {if @order_count == 1, do: "order", else: "orders"}
            </.link>

            <div class="flex gap-2">
              <%= if @product.is_featured do %>
                <span class="rounded-full bg-purple-50 px-3 py-1 text-xs font-semibold text-purple-600">
                  Featured
                </span>
              <% end %>
              <%= if @product.is_bestseller do %>
                <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-semibold text-amber-600">
                  Bestseller
                </span>
              <% end %>
              <%= if @product.is_new_arrival do %>
                <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-600">
                  New Arrival
                </span>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>

    <%!-- Images panel (full width) --%>
    <div class="mb-6 overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
        <p class="text-base font-semibold text-gray-700">
          Images
          <span class="ml-2 rounded-full bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-500">
            {length(@images)}
          </span>
        </p>
      </div>

      <div class="p-6">
        <%!-- Images grid --%>
        <%= if not Enum.empty?(@images) or not Enum.empty?(@uploads.product_image.entries) do %>
          <div class="mb-6 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
            <%= for image <- @images do %>
              <div class="group relative aspect-square">
                <img
                  src={image.image}
                  alt="Product image"
                  class="h-full w-full rounded-xl border border-gray-200 object-cover object-top shadow-sm"
                />
                <button
                  type="button"
                  phx-click="delete_image"
                  phx-value-id={image.id}
                  data-confirm="Remove this image?"
                  class="absolute -right-2 -top-2 flex h-7 w-7 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 opacity-0 shadow-sm transition group-hover:opacity-100 hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                >
                  <svg
                    class="h-3.5 w-3.5"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.5"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
                <span class="absolute bottom-2 left-2 rounded-md bg-black/50 px-1.5 py-0.5 text-[10px] font-semibold text-white">
                  #{image.position}
                </span>
              </div>
            <% end %>

            <%!-- Staged previews --%>
            <%= for entry <- @uploads.product_image.entries do %>
              <div class="group relative aspect-square">
                <.live_img_preview
                  entry={entry}
                  class="h-full w-full rounded-xl border border-gray-200 object-cover object-top shadow-sm"
                />
                <%= if entry.progress > 0 and not entry.done? do %>
                  <div class="absolute inset-x-0 bottom-0 rounded-b-xl bg-black/40 px-3 py-2">
                    <div class="h-1.5 overflow-hidden rounded-full bg-white/30">
                      <div
                        class="h-full rounded-full bg-white transition-all"
                        style={"width: #{entry.progress}%"}
                      />
                    </div>
                  </div>
                <% end %>
                <button
                  type="button"
                  phx-click="cancel_image_upload"
                  phx-value-ref={entry.ref}
                  class="absolute -right-2 -top-2 flex h-7 w-7 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 shadow-sm transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                >
                  <svg
                    class="h-3.5 w-3.5"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.5"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            <% end %>
          </div>
        <% end %>

        <%!-- Upload errors --%>
        <%= for err <- upload_errors(@uploads.product_image) do %>
          <p class="mb-3 flex items-center gap-2 text-sm text-red-500">
            <svg class="h-4 w-4 flex-shrink-0" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
            </svg>
            {upload_error_to_string(err)}
          </p>
        <% end %>

        <%!-- Upload form --%>
        <form phx-submit="upload_images" phx-change="noop" class="space-y-4">
          <.live_file_input
            upload={@uploads.product_image}
            class="block w-full text-sm text-gray-500 file:mr-4 file:rounded-xl file:border-0 file:bg-gray-100 file:px-4 file:py-2.5 file:text-sm file:font-semibold file:text-gray-700 hover:file:bg-gray-200"
          />
          <%= if Enum.any?(@uploads.product_image.entries) do %>
            <button
              type="submit"
              class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700"
            >
              Upload {length(@uploads.product_image.entries)} image{if length(
                                                                         @uploads.product_image.entries
                                                                       ) != 1,
                                                                       do: "s"}
            </button>
          <% end %>
        </form>

        <%= if Enum.empty?(@images) and Enum.empty?(@uploads.product_image.entries) do %>
          <div class="flex flex-col items-center justify-center py-16 text-center">
            <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100">
              <svg
                class="h-7 w-7 text-gray-400"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                <circle cx="8.5" cy="8.5" r="1.5" />
                <polyline points="21 15 16 10 5 21" />
              </svg>
            </div>
            <p class="mt-4 text-base font-semibold text-gray-700">No images yet</p>
            <p class="mt-1.5 text-sm text-gray-400">Select images using the file picker above.</p>
          </div>
        <% end %>
      </div>
    </div>

    <%!-- Variants panel (full width) --%>
    <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
        <p class="text-base font-semibold text-gray-700">
          Variants
          <span class="ml-2 rounded-full bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-500">
            {length(@variants)}
          </span>
        </p>
        <button
          type="button"
          phx-click="toggle_variant_form"
          class={[
            "flex items-center gap-2 rounded-xl border px-4 py-2 text-sm font-semibold transition",
            if(@show_variant_form,
              do: "border-gray-300 bg-gray-100 text-gray-700",
              else: "border-gray-200 text-gray-600 hover:border-gray-300 hover:text-gray-900"
            )
          ]}
        >
          <%= if @show_variant_form do %>
            <svg
              class="h-4 w-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
            Cancel
          <% else %>
            <svg
              class="h-4 w-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            Add Variant
          <% end %>
        </button>
      </div>

      <%!-- Inline add-variant form --%>
      <%= if @show_variant_form do %>
        <div class="border-b border-gray-100 bg-gray-50 px-6 py-6">
          <p class="mb-4 text-xs font-semibold uppercase tracking-widest text-gray-400">
            New Variant
          </p>
          <.form
            for={@variant_form}
            phx-change="validate_variant"
            phx-submit="save_variant"
            class="space-y-4"
          >
            <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
              <%!-- Color name --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Color Name</label>
                <input
                  type="text"
                  name={@variant_form[:color_name].name}
                  value={@variant_form[:color_name].value}
                  id={@variant_form[:color_name].id}
                  placeholder="e.g. Midnight Black"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={msg <- Enum.map(@variant_form[:color_name].errors, &translate_error/1)}>
                  {msg}
                </.error>
              </div>

              <%!-- Color hex --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Color</label>
                <div
                  id="variant-color-picker-add"
                  phx-hook="SyncColorPicker"
                  class="flex items-center overflow-hidden rounded-xl border border-gray-200 bg-white transition focus-within:border-gray-400"
                >
                  <input
                    type="color"
                    value={@variant_form[:color_hex].value || "#000000"}
                    class="h-[42px] w-12 flex-shrink-0 cursor-pointer border-0 bg-transparent p-1"
                  />
                  <input
                    type="text"
                    name={@variant_form[:color_hex].name}
                    value={@variant_form[:color_hex].value || "#000000"}
                    id={@variant_form[:color_hex].id}
                    placeholder="#000000"
                    class="flex-1 bg-transparent px-3 py-2.5 font-mono text-sm text-gray-700 focus:outline-none"
                  />
                </div>
                <.error :for={msg <- Enum.map(@variant_form[:color_hex].errors, &translate_error/1)}>
                  {msg}
                </.error>
              </div>

              <%!-- Size --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Size</label>
                <input
                  type="text"
                  name={@variant_form[:size].name}
                  value={@variant_form[:size].value}
                  id={@variant_form[:size].id}
                  placeholder="e.g. S, M, L, XL"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={msg <- Enum.map(@variant_form[:size].errors, &translate_error/1)}>
                  {msg}
                </.error>
              </div>

              <%!-- Stock --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Stock Qty</label>
                <input
                  type="text"
                  name={@variant_form[:stock_quantity].name}
                  value={@variant_form[:stock_quantity].value}
                  id={@variant_form[:stock_quantity].id}
                  placeholder="e.g. 50"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={
                  msg <- Enum.map(@variant_form[:stock_quantity].errors, &translate_error/1)
                }>
                  {msg}
                </.error>
              </div>
            </div>

            <div class="flex justify-end">
              <button
                type="submit"
                phx-disable-with="Saving..."
                class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700"
              >
                Save Variant
              </button>
            </div>
          </.form>
        </div>
      <% end %>

      <%!-- Inline edit-variant form --%>
      <%= if @editing_variant_id do %>
        <div class="border-b border-gray-100 bg-amber-50 px-6 py-6">
          <div class="mb-4 flex items-center justify-between">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">
              Edit Variant
            </p>
            <button
              type="button"
              phx-click="cancel_edit_variant"
              class="flex items-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs font-semibold text-gray-500 transition hover:border-gray-300 hover:text-gray-700"
            >
              <svg
                class="h-3.5 w-3.5"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.5"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
              Cancel
            </button>
          </div>
          <.form
            for={@edit_variant_form}
            phx-change="validate_edit_variant"
            phx-submit="update_variant"
            class="space-y-4"
          >
            <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
              <%!-- Color name --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Color Name</label>
                <input
                  type="text"
                  name={@edit_variant_form[:color_name].name}
                  value={@edit_variant_form[:color_name].value}
                  id={@edit_variant_form[:color_name].id}
                  placeholder="e.g. Midnight Black"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={
                  msg <- Enum.map(@edit_variant_form[:color_name].errors, &translate_error/1)
                }>
                  {msg}
                </.error>
              </div>

              <%!-- Color hex --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Color</label>
                <div
                  id="variant-color-picker-edit"
                  phx-hook="SyncColorPicker"
                  class="flex items-center overflow-hidden rounded-xl border border-gray-200 bg-white transition focus-within:border-gray-400"
                >
                  <input
                    type="color"
                    value={@edit_variant_form[:color_hex].value || "#000000"}
                    class="h-[42px] w-12 flex-shrink-0 cursor-pointer border-0 bg-transparent p-1"
                  />
                  <input
                    type="text"
                    name={@edit_variant_form[:color_hex].name}
                    value={@edit_variant_form[:color_hex].value || "#000000"}
                    id={@edit_variant_form[:color_hex].id}
                    placeholder="#000000"
                    class="flex-1 bg-transparent px-3 py-2.5 font-mono text-sm text-gray-700 focus:outline-none"
                  />
                </div>
                <.error :for={
                  msg <- Enum.map(@edit_variant_form[:color_hex].errors, &translate_error/1)
                }>
                  {msg}
                </.error>
              </div>

              <%!-- Size --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Size</label>
                <input
                  type="text"
                  name={@edit_variant_form[:size].name}
                  value={@edit_variant_form[:size].value}
                  id={@edit_variant_form[:size].id}
                  placeholder="e.g. S, M, L, XL"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={
                  msg <- Enum.map(@edit_variant_form[:size].errors, &translate_error/1)
                }>
                  {msg}
                </.error>
              </div>

              <%!-- Stock --%>
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Stock Qty</label>
                <input
                  type="text"
                  name={@edit_variant_form[:stock_quantity].name}
                  value={@edit_variant_form[:stock_quantity].value}
                  id={@edit_variant_form[:stock_quantity].id}
                  placeholder="e.g. 50"
                  class="w-full rounded-xl border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none"
                />
                <.error :for={
                  msg <- Enum.map(@edit_variant_form[:stock_quantity].errors, &translate_error/1)
                }>
                  {msg}
                </.error>
              </div>
            </div>

            <div class="flex justify-end">
              <button
                type="submit"
                phx-disable-with="Saving..."
                class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700"
              >
                Update Variant
              </button>
            </div>
          </.form>
        </div>
      <% end %>

      <%!-- Variants list --%>
      <div>
        <%= if Enum.empty?(@variants) do %>
          <div class="flex flex-col items-center justify-center py-16 text-center">
            <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100">
              <svg
                class="h-7 w-7 text-gray-400"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <circle cx="12" cy="12" r="10" />
                <line x1="12" y1="8" x2="12" y2="12" />
                <line x1="12" y1="16" x2="12.01" y2="16" />
              </svg>
            </div>
            <p class="mt-4 text-base font-semibold text-gray-700">No variants yet</p>
            <p class="mt-1.5 text-sm text-gray-400">
              Add size and colour variants using the button above.
            </p>
          </div>
        <% else %>
          <table class="w-full">
            <thead>
              <tr class="border-b border-gray-100 bg-gray-50">
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Color
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Size
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Stock
                </th>
                <th class="px-6 py-3.5 text-right text-xs font-semibold uppercase tracking-wider text-gray-400">
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                :for={variant <- @variants}
                class={[
                  "group border-b border-gray-100 last:border-0 hover:bg-gray-50",
                  if(@editing_variant_id == variant.id, do: "bg-amber-50 hover:bg-amber-50")
                ]}
              >
                <td class="px-6 py-4">
                  <div class="flex items-center gap-3">
                    <span
                      class="h-6 w-6 flex-shrink-0 rounded-full border border-gray-200 shadow-sm"
                      style={"background-color: #{variant.color_hex}"}
                    />
                    <span class="text-sm font-medium text-gray-800">{variant.color_name}</span>
                    <span class="font-mono text-xs text-gray-400">{variant.color_hex}</span>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <span class="rounded-lg border border-gray-200 bg-gray-50 px-3 py-1 text-sm font-semibold text-gray-700">
                    {variant.size}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <span class="text-sm font-medium text-gray-700">
                    {variant.stock_quantity} units
                  </span>
                </td>
                <td class="px-6 py-4 text-right">
                  <div class="flex items-center justify-end gap-2">
                    <button
                      phx-click="edit_variant"
                      phx-value-id={variant.id}
                      class={[
                        "flex h-8 w-8 items-center justify-center rounded-lg border text-gray-400 transition",
                        if(@editing_variant_id == variant.id,
                          do: "border-amber-300 bg-amber-100 text-amber-600",
                          else:
                            "border-gray-200 opacity-0 group-hover:opacity-100 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700"
                        )
                      ]}
                    >
                      <svg
                        class="h-3.5 w-3.5"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                      >
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                      </svg>
                    </button>
                    <button
                      phx-click="delete_variant"
                      phx-value-id={variant.id}
                      data-confirm="Delete this variant?"
                      class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 opacity-0 transition group-hover:opacity-100 hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                    >
                      <svg
                        class="h-3.5 w-3.5"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                      >
                        <polyline points="3 6 5 6 21 6" />
                        <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6" />
                        <path d="M10 11v6m4-6v6" />
                        <path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        <% end %>
      </div>
    </div>

    <%!-- Edit modal --%>
    <.modal
      :if={@live_action == :edit}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/admin/products/#{@product}")}
    >
      <.live_component
        module={SheglowWeb.ProductLive.FormComponent}
        id={@product.id}
        title="Edit Product"
        action={@live_action}
        product={@product}
        collections={Sheglow.Collections.list_collections()}
        patch={~p"/admin/products/#{@product}"}
      />
    </.modal>
    """
  end
end
