defmodule SheglowWeb.AdminPageLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.InfoPages

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Info Pages")
     |> assign(:current_path, "/admin/pages")
     |> assign(:pages, InfoPages.list_info_pages())
     |> assign(:editing_id, nil)
     |> assign(:form, nil)
     |> assign(:save_error, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    page = InfoPages.get_info_page!(id)
    {:noreply, open_form(socket, page)}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    page = InfoPages.get_info_page!(id)
    {:noreply, open_form(socket, page)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> assign(:editing_id, nil) |> assign(:form, nil) |> assign(:save_error, nil)}
  end

  def handle_event("validate", %{"info_page" => params}, socket) do
    changeset =
      socket.assigns.form.data
      |> InfoPages.change_info_page(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "info_page"))}
  end

  def handle_event("save", %{"info_page" => params}, socket) do
    page = socket.assigns.form.data

    case InfoPages.update_info_page(page, params) do
      {:ok, _updated} ->
        {:noreply,
         socket
         |> assign(:pages, InfoPages.list_info_pages())
         |> assign(:editing_id, nil)
         |> assign(:form, nil)
         |> assign(:save_error, nil)
         |> put_flash(:info, "Page saved.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: "info_page"))
         |> assign(:save_error, "Please fix the errors below.")}
    end
  end

  def handle_event("toggle_active", %{"id" => id}, socket) do
    page = InfoPages.get_info_page!(id)
    {:ok, _} = InfoPages.update_info_page(page, %{is_active: !page.is_active})
    {:noreply, assign(socket, :pages, InfoPages.list_info_pages())}
  end

  # ── Helpers ──────────────────────────────────────────────────────────────────

  defp open_form(socket, page) do
    changeset = InfoPages.change_info_page(page)
    socket
    |> assign(:editing_id, page.id)
    |> assign(:form, to_form(changeset, as: "info_page"))
    |> assign(:save_error, nil)
  end

  defp icon_for(slug) do
    case slug do
      "how-to-order"        -> "🛍️"
      "size-guide"          -> "📐"
      "shipping-delivery"   -> "🚚"
      "returns-exchanges"   -> "🔄"
      _                     -> "📄"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%!-- Page header --%>
      <div class="mb-8 flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-bold text-gray-900">Info Pages</h1>
          <p class="mt-1 text-sm text-gray-500">
            Manage customer-facing pages shown in the footer
          </p>
        </div>
        <a
          href="/info/how-to-order"
          target="_blank"
          class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2 text-sm font-medium text-gray-600 shadow-sm transition hover:border-[#C8001F]/40 hover:text-[#C8001F]"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
          </svg>
          Preview site
        </a>
      </div>

      <div>

        <%!-- Edit form --%>
        <%= if @form do %>
          <% page = @form.data %>
          <div class="mb-8 overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
            <div class="flex items-center justify-between border-b border-gray-100 px-6 py-4">
              <div class="flex items-center gap-2">
                <span class="text-lg">{icon_for(page.slug)}</span>
                <h2 class="text-base font-semibold text-gray-900">Editing: {page.title}</h2>
              </div>
              <button
                type="button"
                phx-click="cancel"
                class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition"
              >
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <.form for={@form} phx-change="validate" phx-submit="save" class="p-6 space-y-5">
              <%= if @save_error do %>
                <p class="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-600">{@save_error}</p>
              <% end %>

              <div class="grid gap-5 sm:grid-cols-2">
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                    Page Title <span class="text-red-500">*</span>
                  </label>
                  <.input
                    field={@form[:title]}
                    type="text"
                    placeholder="e.g. How to Order"
                    class="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                  />
                </div>
                <div>
                  <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                    URL Slug
                    <span class="ml-1 text-xs font-normal text-gray-400">(cannot change)</span>
                  </label>
                  <div class="flex items-center rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm text-gray-500">
                    /info/<strong class="text-gray-700">{page.slug}</strong>
                  </div>
                </div>
              </div>

              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                  Meta Description
                  <span class="ml-1 text-xs font-normal text-gray-400">(max 160 chars — used by Google)</span>
                </label>
                <.input
                  field={@form[:meta_description]}
                  type="text"
                  placeholder="Short description for search engines"
                  class="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                />
              </div>

              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">
                  Page Content
                </label>
                <p class="mb-2 text-xs text-gray-400">
                  Supports simple formatting: <code class="rounded bg-gray-100 px-1">## Heading</code>,
                  <code class="rounded bg-gray-100 px-1">### Sub-heading</code>,
                  <code class="rounded bg-gray-100 px-1">**bold**</code>,
                  <code class="rounded bg-gray-100 px-1">- list item</code>
                </p>
                <.input
                  field={@form[:content]}
                  type="textarea"
                  rows="18"
                  placeholder="Write your page content here..."
                  class="w-full rounded-xl border border-gray-300 px-4 py-3 font-mono text-sm leading-relaxed focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                />
              </div>

              <div class="flex items-center gap-3 pt-2">
                <button
                  type="submit"
                  class="rounded-xl bg-[#C8001F] px-6 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-[var(--brand-primary-dark)]"
                >
                  Save Page
                </button>
                <button
                  type="button"
                  phx-click="cancel"
                  class="rounded-xl border border-gray-300 px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50"
                >
                  Cancel
                </button>
                <a
                  href={"/info/#{page.slug}"}
                  target="_blank"
                  class="ml-auto text-sm text-[#C8001F] hover:underline"
                >
                  Preview →
                </a>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- Pages list --%>
        <div class="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-100 px-6 py-4">
            <h2 class="text-base font-semibold text-gray-900">
              All Pages
              <span class="ml-2 rounded-full bg-gray-100 px-2 py-0.5 text-xs font-medium text-gray-600">
                {length(@pages)}
              </span>
            </h2>
          </div>

          <%= if @pages == [] do %>
            <div class="px-6 py-16 text-center">
              <p class="text-4xl">📄</p>
              <p class="mt-3 text-sm font-medium text-gray-500">No pages yet. Run seeds to add the default pages.</p>
            </div>
          <% else %>
            <div class="divide-y divide-gray-100">
              <%= for page <- @pages do %>
                <div class={"flex items-start gap-4 px-6 py-5 transition hover:bg-gray-50 #{if @editing_id == page.id, do: "bg-[#C8001F]/3"}"}>
                  <div class="mt-0.5 flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-2xl bg-gray-100 text-xl">
                    {icon_for(page.slug)}
                  </div>
                  <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                      <span class="text-sm font-semibold text-gray-900">{page.title}</span>
                      <span class="rounded-full bg-gray-100 px-2 py-0.5 font-mono text-[11px] text-gray-500">
                        /info/{page.slug}
                      </span>
                      <%= if page.is_active do %>
                        <span class="rounded-full bg-green-100 px-2 py-0.5 text-[11px] font-medium text-green-700">Active</span>
                      <% else %>
                        <span class="rounded-full bg-gray-100 px-2 py-0.5 text-[11px] font-medium text-gray-500">Draft</span>
                      <% end %>
                    </div>
                    <p class="mt-0.5 truncate text-xs text-gray-400">
                      <%= if page.content && page.content != "" do %>
                        {String.slice(page.content, 0, 100)}<%= if String.length(page.content || "") > 100, do: "…" %>
                      <% else %>
                        <span class="italic">No content yet</span>
                      <% end %>
                    </p>
                  </div>
                  <div class="flex flex-shrink-0 items-center gap-2">
                    <button
                      type="button"
                      phx-click="toggle_active"
                      phx-value-id={page.id}
                      class={"rounded-lg px-3 py-1.5 text-xs font-medium transition #{if page.is_active, do: "bg-green-50 text-green-700 hover:bg-green-100", else: "bg-gray-100 text-gray-500 hover:bg-gray-200"}"}
                    >
                      {if page.is_active, do: "Published", else: "Draft"}
                    </button>
                    <button
                      type="button"
                      phx-click="edit"
                      phx-value-id={page.id}
                      class="rounded-lg border border-[#C8001F]/30 bg-[#C8001F]/5 px-3 py-1.5 text-xs font-medium text-[#C8001F] transition hover:bg-[#C8001F] hover:text-white"
                    >
                      Edit
                    </button>
                    <a
                      href={"/info/#{page.slug}"}
                      target="_blank"
                      class="rounded-lg border border-gray-200 p-1.5 text-gray-400 transition hover:border-gray-400 hover:text-gray-700"
                    >
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                      </svg>
                    </a>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
