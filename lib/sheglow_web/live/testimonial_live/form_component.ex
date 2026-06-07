defmodule SheglowWeb.TestimonialLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.Testimonials
  alias Sheglow.Products

  @impl true
  def update(%{testimonial: testimonial} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> assign(:products, Products.list_products())
     |> assign_new(:form, fn ->
       to_form(Testimonials.change_testimonial(testimonial))
     end)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"testimonial" => params}, socket) do
    changeset = Testimonials.change_testimonial(socket.assigns.testimonial, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"testimonial" => params}, socket) do
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

    params =
      case List.first(uploaded_files) do
        nil -> params
        url -> Map.put(params, "image", url)
      end

    save_testimonial(socket, socket.assigns.action, params)
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("clear_image", _, socket) do
    changeset = Testimonials.change_testimonial(socket.assigns.testimonial, %{"image" => nil})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # ── Save ──────────────────────────────────────────────────────────

  defp save_testimonial(socket, :edit, params) do
    case Testimonials.update_testimonial(socket.assigns.testimonial, params) do
      {:ok, testimonial} ->
        notify_parent({:saved, testimonial})

        {:noreply,
         socket
         |> put_flash(:info, "Testimonial updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_testimonial(socket, :new, params) do
    case Testimonials.create_testimonial(params) do
      {:ok, testimonial} ->
        notify_parent({:saved, testimonial})

        {:noreply,
         socket
         |> put_flash(:info, "Testimonial created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp has_saved_image?(v) when is_binary(v) and byte_size(v) > 0, do: true
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
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Store</p>
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
        id="testimonial-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <%!-- Customer photo --%>
        <div>
          <label class="mb-1.5 block text-sm font-semibold text-gray-700">Customer Photo</label>
          <div class="space-y-3">
            <%= if has_saved_image?(@saved_image) and Enum.empty?(@pending_entries) do %>
              <div class="relative w-fit">
                <img
                  src={@saved_image}
                  alt="Customer photo"
                  class="h-20 w-20 rounded-full border border-gray-200 object-cover object-top shadow-sm"
                />
                <button
                  type="button"
                  phx-click="clear_image"
                  phx-target={@myself}
                  class="absolute -right-1 -top-1 flex h-6 w-6 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 shadow-sm transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
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

            <%= for entry <- @pending_entries do %>
              <div class="relative w-fit">
                <.live_img_preview
                  entry={entry}
                  class="h-20 w-20 rounded-full border border-gray-200 object-cover object-top shadow-sm"
                />
                <button
                  type="button"
                  phx-click="cancel_upload"
                  phx-value-ref={entry.ref}
                  phx-target={@myself}
                  class="absolute -right-1 -top-1 flex h-6 w-6 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-400 shadow-sm transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
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
                <%= for err <- upload_errors(@uploads.image, entry) do %>
                  <p class="text-xs text-red-500">{upload_error_to_string(err)}</p>
                <% end %>
              </div>
            <% end %>

            <.live_file_input upload={@uploads.image} />

            <%= for err <- upload_errors(@uploads.image) do %>
              <p class="text-xs text-red-500">{upload_error_to_string(err)}</p>
            <% end %>
          </div>
        </div>

        <%!-- Details --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Details
          </p>
          <div class="space-y-4">
            <%!-- Name --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Customer Name</label>
              <input
                type="text"
                name={@form[:name].name}
                value={@form[:name].value}
                id={@form[:name].id}
                phx-debounce="blur"
                placeholder="e.g. Jane Doe"
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              />
              <.error :for={msg <- Enum.map(@form[:name].errors, &translate_error/1)}>{msg}</.error>
            </div>

            <%!-- Body --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Review</label>
              <textarea
                name={@form[:body].name}
                id={@form[:body].id}
                phx-debounce="blur"
                rows="4"
                placeholder="What did the customer say..."
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >{@form[:body].value}</textarea>
              <.error :for={msg <- Enum.map(@form[:body].errors, &translate_error/1)}>{msg}</.error>
            </div>

            <%!-- Rating --%>
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Rating (1–5)</label>
              <div class="flex items-center gap-1" id="star-rating">
                <%= for i <- 1..5 do %>
                  <label class="cursor-pointer">
                    <input
                      type="radio"
                      name={@form[:rating].name}
                      value={i}
                      checked={to_string(@form[:rating].value) == to_string(i)}
                      class="sr-only"
                    />
                    <svg
                      class={[
                        "h-8 w-8 transition hover:scale-110",
                        if(
                          to_string(@form[:rating].value) != "" and
                            String.to_integer(to_string(@form[:rating].value || 0)) >= i,
                          do: "text-amber-400",
                          else: "text-gray-200 hover:text-amber-300"
                        )
                      ]}
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
                    </svg>
                  </label>
                <% end %>
              </div>
              <.error :for={msg <- Enum.map(@form[:rating].errors, &translate_error/1)}>{msg}</.error>
            </div>
          </div>
        </div>

        <%!-- Linked product --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Linked Product
          </p>
          <div>
            <label class="mb-1.5 block text-sm font-semibold text-gray-700">
              Product <span class="font-normal text-gray-400">(optional)</span>
            </label>
            <select
              name={@form[:product_id].name}
              id={@form[:product_id].id}
              class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 transition focus:border-gray-400 focus:outline-none focus:ring-0"
            >
              <option value="">— No product —</option>
              <%= for product <- @products do %>
                <option
                  value={product.id}
                  selected={to_string(@form[:product_id].value) == to_string(product.id)}
                >
                  {product.name}
                </option>
              <% end %>
            </select>
          </div>
        </div>

        <%!-- Display settings --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Display
          </p>
          <div class="grid grid-cols-2 gap-4">
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

            <%!-- Active --%>
            <div class="flex items-end">
              <label class="flex w-full cursor-pointer items-center gap-2.5 rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 transition hover:bg-gray-50">
                <input type="hidden" name={@form[:is_active].name} value="false" />
                <input
                  type="checkbox"
                  name={@form[:is_active].name}
                  value="true"
                  checked={@form[:is_active].value}
                  id={@form[:is_active].id}
                  class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-0"
                />
                <span class="text-sm font-semibold text-gray-700">Active</span>
              </label>
            </div>
          </div>
        </div>

        <%!-- Footer --%>
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
            {if @action == :new, do: "Add Testimonial", else: "Save Changes"}
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
