defmodule SheglowWeb.BundleLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.Bundles

  @impl true
  def update(%{bundle: bundle} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> assign_new(:form, fn ->
       to_form(Bundles.change_bundle(bundle))
     end)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"bundle" => bundle_params}, socket) do
    changeset = Bundles.change_bundle(socket.assigns.bundle, bundle_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"bundle" => bundle_params}, socket) do
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

    bundle_params =
      case List.first(uploaded_files) do
        nil -> bundle_params
        url -> Map.put(bundle_params, "image", url)
      end

    save_bundle(socket, socket.assigns.action, bundle_params)
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("clear_image", _, socket) do
    changeset = Bundles.change_bundle(socket.assigns.bundle, %{"image" => nil})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # ── Save ──────────────────────────────────────────────────────────

  defp save_bundle(socket, :edit, bundle_params) do
    case Bundles.update_bundle(socket.assigns.bundle, bundle_params) do
      {:ok, bundle} ->
        notify_parent({:saved, bundle})

        {:noreply,
         socket
         |> put_flash(:info, "Bundle updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bundle(socket, :new, bundle_params) do
    case Bundles.create_bundle(bundle_params) do
      {:ok, bundle} ->
        notify_parent({:saved, bundle})

        {:noreply,
         socket
         |> put_flash(:info, "Bundle created successfully")
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
        id="bundle-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <%!-- Image --%>
        <div>
          <label class="mb-1.5 block text-sm font-semibold text-gray-700">Bundle Image</label>
          <div class="space-y-3">
            <%= if has_saved_image?(@saved_image) and Enum.empty?(@pending_entries) do %>
              <div class="relative w-fit">
                <img
                  src={@saved_image}
                  alt="Bundle image"
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

            <%= for entry <- @pending_entries do %>
              <div class="relative w-fit">
                <.live_img_preview
                  entry={entry}
                  class="h-36 w-36 rounded-xl border border-gray-200 object-cover object-top shadow-sm"
                />
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
                <%= for err <- upload_errors(@uploads.image, entry) do %>
                  <p class="flex items-center gap-1.5 text-xs text-red-500">
                    {upload_error_to_string(err)}
                  </p>
                <% end %>
              </div>
            <% end %>

            <.live_file_input upload={@uploads.image} />

            <%= for err <- upload_errors(@uploads.image) do %>
              <p class="flex items-center gap-1.5 text-xs text-red-500">
                {upload_error_to_string(err)}
              </p>
            <% end %>
          </div>
        </div>

        <%!-- Basic Info --%>
        <div>
          <p class="mb-3 text-[11px] font-semibold uppercase tracking-widest text-gray-400">
            Details
          </p>
          <div class="space-y-4">
            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Title</label>
              <input
                type="text"
                name={@form[:title].name}
                value={@form[:title].value}
                id={@form[:title].id}
                phx-debounce="blur"
                placeholder="e.g. Summer Essentials Bundle"
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              />
              <.error :for={msg <- Enum.map(@form[:title].errors, &translate_error/1)}>{msg}</.error>
            </div>

            <div>
              <label class="mb-1.5 block text-sm font-semibold text-gray-700">Description</label>
              <textarea
                name={@form[:description].name}
                id={@form[:description].id}
                phx-debounce="blur"
                rows="3"
                placeholder="Short bundle description..."
                class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
              >{@form[:description].value}</textarea>
              <.error :for={msg <- Enum.map(@form[:description].errors, &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <div>
              <label class="flex cursor-pointer items-center gap-2.5 rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 transition hover:bg-gray-50">
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
            {if @action == :new, do: "Create Bundle", else: "Save Changes"}
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
