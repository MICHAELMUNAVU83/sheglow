defmodule SheglowWeb.CollectionLive.FormComponent do
  use SheglowWeb, :live_component

  alias Sheglow.Collections

  @impl true
  def update(%{collection: collection} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:uploaded_files, [])
     |> assign_new(:form, fn ->
       to_form(Collections.change_collection(collection))
     end)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"collection" => collection_params}, socket) do
    changeset = Collections.change_collection(socket.assigns.collection, collection_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"collection" => collection_params}, socket) do
    # 1. Consume uploaded entries first — exactly as the article shows
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

    # Debugging line
    IO.inspect(uploaded_files, label: "Uploaded files")

    # 2. Update uploaded_files assign
    socket = update(socket, :uploaded_files, &(&1 ++ uploaded_files))

    # 3. Merge the image URL into params (keep existing if no new upload)
    collection_params =
      case List.first(uploaded_files) do
        nil -> collection_params
        url -> Map.put(collection_params, "image", url)
      end

    # 4. Save
    save_collection(socket, socket.assigns.action, collection_params)
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("clear_image", _, socket) do
    changeset = Collections.change_collection(socket.assigns.collection, %{"image" => nil})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # ── Save ──────────────────────────────────────────────────────────

  defp save_collection(socket, :edit, collection_params) do
    case Collections.update_collection(socket.assigns.collection, collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_collection(socket, :new, collection_params) do
    case Collections.create_collection(collection_params) do
      {:ok, collection} ->
        notify_parent({:saved, collection})

        {:noreply,
         socket
         |> put_flash(:info, "Collection created successfully")
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
      </div>

      <.simple_form
        for={@form}
        id="collection-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-5"
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

        <%!-- ── Title ─────────────────────────────────────────── --%>
        <div>
          <label class="mb-1.5 block text-sm font-semibold text-gray-700">Title</label>
          <input
            type="text"
            name={@form[:title].name}
            value={@form[:title].value}
            id={@form[:title].id}
            phx-debounce="blur"
            placeholder="e.g. Summer Dresses"
            class="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:outline-none focus:ring-0"
          />
          <.error :for={msg <- Enum.map(@form[:title].errors, &translate_error/1)}>
            {msg}
          </.error>
        </div>

        <%!-- ── Slug ──────────────────────────────────────────── --%>
        <div>
          <label class="mb-1.5 block text-sm font-semibold text-gray-700">Slug</label>
          <div class="flex items-center overflow-hidden rounded-lg border border-gray-200 bg-white transition focus-within:border-gray-400">
            <span class="select-none border-r border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-gray-400">
              /collections/
            </span>
            <input
              type="text"
              name={@form[:slug].name}
              value={@form[:slug].value}
              id={@form[:slug].id}
              phx-debounce="blur"
              placeholder="summer-dresses"
              class="flex-1 bg-white px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"
            />
          </div>
          <.error :for={msg <- Enum.map(@form[:slug].errors, &translate_error/1)}>
            {msg}
          </.error>
        </div>

        <%!-- ── Position + Status ──────────────────────────────── --%>
        <div class="grid grid-cols-2 gap-4">
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

          <div>
            <label class="mb-1.5 block text-sm font-semibold text-gray-700">Status</label>
            <label class="flex h-[42px] cursor-pointer items-center gap-3 rounded-lg border border-gray-200 bg-white px-3.5 transition hover:bg-gray-50">
              <input type="hidden" name={@form[:is_active].name} value="false" />
              <input
                type="checkbox"
                name={@form[:is_active].name}
                checked={@form[:is_active].value}
                id={@form[:is_active].id}
                value="true"
                class="h-4 w-4 rounded border-gray-300 text-gray-900 focus:ring-0 focus:ring-offset-0"
              />
              <span class="text-sm text-gray-700">Active</span>
            </label>
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
            {if @action == :new, do: "Create Collection", else: "Save Changes"}
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
