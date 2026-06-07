defmodule SheglowWeb.ProductLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.Products

  @impl true
  def update(%{product: product} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> assign_new(:form, fn ->
       to_form(Products.change_product(product))
     end)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset = Products.change_product(socket.assigns.product, product_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"product" => product_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
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

    socket = update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    product_params =
      case List.first(uploaded_files) do
        nil -> product_params
        url -> Map.put(product_params, "image", url)
      end

    save_product(socket, socket.assigns.action, product_params)
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("clear_image", _, socket) do
    changeset = Products.change_product(socket.assigns.product, %{"image" => nil})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # ── Save ──────────────────────────────────────────────────────────

  defp save_product(socket, :edit, product_params) do
    case IO.inspect(Products.update_product(socket.assigns.product, product_params)) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product(socket, :new, product_params) do
    case IO.inspect(Products.create_product(product_params)) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp has_saved_image?(value) when is_binary(value) and byte_size(value) > 0, do: true
  defp has_saved_image?(_), do: false

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp upload_error_to_string(:too_large), do: "File is too large (max 5 MB)"
  defp upload_error_to_string(:not_accepted), do: "Unsupported file type"
  defp upload_error_to_string(:too_many_files), do: "Only one image allowed"
  defp upload_error_to_string(err), do: "Upload error: #{inspect(err)}"

  # ── Render ────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        saved_image: assigns.form[:image].value,
        pending_entries: assigns.uploads.image.entries
      )

    ~H"""
    <div>
      <%!-- Header --%>
      <div class="mb-6 flex items-start justify-between">
        <div>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Catalogue</p>
          <h2 class="mt-1 text-xl font-bold text-gray-900">{@title}</h2>
        </div>
        <.link patch={@patch}>
          <button
            type="button"
            class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700"
          >
            <svg
              class="h-4 w-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </.link>
      </div>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <%!-- ── Image ──────────────────────────────────────────── --%>
        <div>
          <label class="mb-1.5 block text-sm font-semibold text-gray-700">Collection Image</label>

          <div class="space-y-3">
            <%!-- A) Existing saved image — edit mode, no new file staged --%>
            <%= if has_saved_image?(@saved_image) and Enum.empty?(@pending_entries) do %>
              <div class="relative w-fit">
                <img
                  src={@saved_image}
                  alt="Current collection image"
                  class="h-36 w-36 rounded-xl border border-gray-200 object-cover object-top shadow-sm"
                />
                <button
                  type="button"
                  phx-click="clear_image"
                  phx-target={@myself}
                  class="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 shadow-sm transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                >
                  <svg
                    class="h-3 w-3"
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

            <%!-- B) Live preview of staged file --%>
            <%= for entry <- @pending_entries do %>
              <div class="relative w-fit">
                <.live_img_preview
                  entry={entry}
                  class="h-36 w-36 rounded-xl border border-gray-200 object-cover object-top shadow-sm"
                />
                <%!-- Progress bar --%>
                <%= if entry.progress > 0 and not entry.done? do %>
                  <div class="absolute inset-x-0 bottom-0 rounded-b-xl bg-black/40 px-3 py-1.5">
                    <div class="h-1 overflow-hidden rounded-full bg-white/30">
                      <div
                        class="h-full rounded-full bg-white transition-all duration-300"
                        style={"width: #{entry.progress}%"}
                      />
                    </div>
                  </div>
                <% end %>
                <%!-- Remove staged file --%>
                <button
                  type="button"
                  phx-click="cancel_upload"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  class="absolute -right-2 -top-2 flex h-6 w-6 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 shadow-sm transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                >
                  <svg
                    class="h-3 w-3"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.5"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <%!-- Per-entry upload errors --%>
              <%= for err <- upload_errors(@uploads.image, entry) do %>
                <p class="flex items-center gap-1.5 text-xs text-red-500">
                  <svg class="h-3.5 w-3.5 flex-shrink-0" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
                  </svg>
                  {upload_error_to_string(err)}
                </p>
              <% end %>
            <% end %>

            <.live_file_input upload={@uploads.image} />

            <%!-- Global upload errors --%>
            <%= for err <- upload_errors(@uploads.image) do %>
              <p class="flex items-center gap-1.5 text-xs text-red-500">
                <svg class="h-3.5 w-3.5 flex-shrink-0" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
                </svg>
                {upload_error_to_string(err)}
              </p>
            <% end %>
          </div>
        </div>

        <%!-- ── Section divider: Basic Info ───────────────────── --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Basic Info
          </p>
          <div class="space-y-4">
            <%!-- Name --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Name</label>
              <input
                type="text"
                name={@form[:name].name}
                value={@form[:name].value}
                id={@form[:name].id}
                phx-debounce="blur"
                placeholder="e.g. Floral Wrap Dress"
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              />
              <.error :for={msg <- Enum.map(@form[:name].errors, &translate_error/1)}>{msg}</.error>
            </div>

            <%!-- Slug --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Slug</label>
              <div class="flex items-center overflow-hidden rounded-lg border border-gray-200 bg-white transition focus-within:border-gray-400">
                <span class="select-none border-r border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-gray-400">
                  /products/
                </span>
                <input
                  type="text"
                  name={@form[:slug].name}
                  value={@form[:slug].value}
                  id={@form[:slug].id}
                  phx-debounce="blur"
                  placeholder="floral-wrap-dress"
                  class="flex-1 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"
                />
              </div>
              <.error :for={msg <- Enum.map(@form[:slug].errors, &translate_error/1)}>{msg}</.error>
            </div>

            <%!-- Description --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Description</label>
              <textarea
                name={@form[:description].name}
                id={@form[:description].id}
                phx-debounce="blur"
                rows="3"
                placeholder="Short product description..."
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >{@form[:description].value}</textarea>
              <.error :for={msg <- Enum.map(@form[:description].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <%!-- Collection --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Collection</label>
              <select
                name={@form[:collection_id].name}
                id={@form[:collection_id].id}
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >
                <option value="">— None —</option>
                <%= for collection <- @collections do %>
                  <option
                    value={collection.id}
                    selected={to_string(@form[:collection_id].value) == to_string(collection.id)}
                  >
                    {collection.title}
                  </option>
                <% end %>
              </select>
              <.error :for={msg <- Enum.map(@form[:collection_id].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>
          </div>
        </div>

        <%!-- ── Section divider: Pricing & Position ───────────── --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Pricing & Display
          </p>
          <div class="grid grid-cols-2 gap-4">
            <%!-- Base price --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Base Price (Ksh)</label>
              <div class="flex items-center overflow-hidden rounded-lg border border-gray-200 bg-white transition focus-within:border-gray-400">
                <span class="select-none border-r border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-gray-400">
                  Ksh
                </span>
                <input
                  type="number"
                  name={@form[:base_price].name}
                  value={@form[:base_price].value}
                  id={@form[:base_price].id}
                  min="0"
                  step="0.01"
                  placeholder="0.00"
                  class="flex-1 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"
                />
              </div>
              <.error :for={msg <- Enum.map(@form[:base_price].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <%!-- Position --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Position</label>
              <input
                type="number"
                name={@form[:position].name}
                value={@form[:position].value}
                id={@form[:position].id}
                min="1"
                placeholder="1"
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              />
              <.error :for={msg <- Enum.map(@form[:position].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <%!-- Status --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Status</label>
              <select
                name={@form[:status].name}
                id={@form[:status].id}
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >
                <option value="draft" selected={@form[:status].value == "draft"}>Draft</option>
                <option value="active" selected={@form[:status].value == "active"}>Active</option>
                <option value="archived" selected={@form[:status].value == "archived"}>
                  Archived
                </option>
              </select>
              <.error :for={msg <- Enum.map(@form[:status].errors, &translate_error/1)}>{msg}</.error>
            </div>
          </div>
        </div>

        <%!-- ── Section divider: Badge ─────────────────────────── --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Badge
          </p>
          <div class="grid grid-cols-2 gap-4">
            <%!-- Badge label --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Label</label>
              <input
                type="text"
                name={@form[:badge_label].name}
                value={@form[:badge_label].value}
                id={@form[:badge_label].id}
                phx-debounce="blur"
                placeholder="e.g. Sale, New, Hot"
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              />
              <.error :for={msg <- Enum.map(@form[:badge_label].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <%!-- Badge color --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Color</label>
              <div
                class="flex items-center overflow-hidden rounded-lg border border-gray-200 bg-white transition focus-within:border-gray-400"
                id="badge-color-picker"
                phx-hook="SyncColorPicker"
              >
                <input
                  type="color"
                  id="badge-color-swatch"
                  value={@form[:badge_color].value || "#f3f4f6"}
                  class="h-[42px] w-12 flex-shrink-0 cursor-pointer border-0 bg-transparent p-1"
                />
                <input
                  type="text"
                  id="badge-color-text"
                  name={@form[:badge_color].name}
                  value={@form[:badge_color].value || "#f3f4f6"}
                  readonly
                  class="flex-1 cursor-default bg-transparent px-3 py-2.5 font-mono text-sm text-gray-700 focus:outline-none"
                />
              </div>
              <.error :for={msg <- Enum.map(@form[:badge_color].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>
          </div>
        </div>

        <%!-- ── Section divider: Flags ─────────────────────────── --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Tags
          </p>
          <div class="grid grid-cols-3 gap-3">
            <label class="flex cursor-pointer items-center gap-2.5 rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 transition hover:bg-gray-50">
              <input type="hidden" name={@form[:is_featured].name} value="false" />
              <input
                type="checkbox"
                name={@form[:is_featured].name}
                value="true"
                checked={@form[:is_featured].value}
                id={@form[:is_featured].id}
                class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-0"
              />
              <span class="text-sm text-gray-700">Featured</span>
            </label>

            <label class="flex cursor-pointer items-center gap-2.5 rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 transition hover:bg-gray-50">
              <input type="hidden" name={@form[:is_bestseller].name} value="false" />
              <input
                type="checkbox"
                name={@form[:is_bestseller].name}
                value="true"
                checked={@form[:is_bestseller].value}
                id={@form[:is_bestseller].id}
                class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-0"
              />
              <span class="text-sm text-gray-700">Bestseller</span>
            </label>

            <label class="flex cursor-pointer items-center gap-2.5 rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 transition hover:bg-gray-50">
              <input type="hidden" name={@form[:is_new_arrival].name} value="false" />
              <input
                type="checkbox"
                name={@form[:is_new_arrival].name}
                value="true"
                checked={@form[:is_new_arrival].value}
                id={@form[:is_new_arrival].id}
                class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-0"
              />
              <span class="text-sm text-gray-700">New Arrival</span>
            </label>
          </div>
        </div>

        <%!-- ── Section divider: Content ───────────────────────── --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Product Content
          </p>
          <div class="space-y-4">
            <%!-- Size Advice --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Size Advice</label>
              <textarea
                name={@form[:size_advice].name}
                id={@form[:size_advice].id}
                phx-debounce="blur"
                rows="3"
                placeholder="e.g. This item runs true to size. We recommend ordering your usual size..."
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >{@form[:size_advice].value}</textarea>
              <.error :for={msg <- Enum.map(@form[:size_advice].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <%!-- Shipping & Returns --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                Shipping & Returns
              </label>
              <textarea
                name={@form[:shipping_returns].name}
                id={@form[:shipping_returns].id}
                phx-debounce="blur"
                rows="3"
                placeholder="e.g. Free standard shipping on orders over Ksh 5,000. Returns accepted within 30 days..."
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >{@form[:shipping_returns].value}</textarea>
              <.error :for={msg <- Enum.map(@form[:shipping_returns].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>
          </div>
        </div>

        <%!-- ── Footer actions ────────────────────────────────── --%>
        <div class="flex items-center justify-between border-t border-gray-100 pt-4">
          <.link patch={@patch}>
            <button
              type="button"
              class="rounded-lg border border-gray-200 px-4 py-2.5 text-sm font-semibold text-gray-600 transition hover:border-gray-300 hover:text-gray-900"
            >
              Cancel
            </button>
          </.link>

          <button
            type="submit"
            phx-disable-with="Saving..."
            class="rounded-lg bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700"
          >
            {if @action == :new, do: "Create Product", else: "Save Changes"}
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
