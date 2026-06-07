defmodule SheglowWeb.BundleLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Bundles
  alias Sheglow.Bundles.Bundle

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Bundles")
     |> assign(:current_path, "/admin/bundles")
     |> stream(:bundles, Bundles.list_bundles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bundle")
    |> assign(:bundle, Bundles.get_bundle!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bundle")
    |> assign(:bundle, %Bundle{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Bundles")
    |> assign(:bundle, nil)
  end

  @impl true
  def handle_info({SheglowWeb.BundleLive.FormComponent, {:saved, bundle}}, socket) do
    {:noreply, stream_insert(socket, :bundles, bundle)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bundle = Bundles.get_bundle!(id)
    {:ok, _} = Bundles.delete_bundle(bundle)
    {:noreply, stream_delete(socket, :bundles, bundle)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page Header --%>
    <div class="relative mb-6 overflow-hidden rounded-3xl bg-gradient-to-r from-[#C8001F] to-[#8b0014] px-7 py-6 text-white shadow-md">
      <div class="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-white/5"></div>
      <div class="flex items-center justify-between">
        <div>
          <p class="text-xs font-medium uppercase tracking-widest text-red-200">Catalogue</p>
          <h1 class="mt-0.5 font-serif text-2xl font-bold">Bundles</h1>
        </div>
        <.link patch={~p"/admin/bundles/new"}>
          <button class="flex items-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-[#C8001F] transition hover:bg-red-50 shadow-sm">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            New Bundle
          </button>
        </.link>
      </div>
    </div>

    <%!-- Table card --%>
    <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
      <div class="border-b border-gray-100 px-5 py-4">
        <p class="font-serif text-sm font-semibold text-gray-700">All Bundles</p>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-gray-100 bg-gray-50">
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Bundle
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Description
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Status
              </th>
              <th class="px-5 py-3 text-right text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Actions
              </th>
            </tr>
          </thead>

          <tbody id="bundles" phx-update="stream">
            <tr
              :for={{id, bundle} <- @streams.bundles}
              id={id}
              class="group border-b border-gray-100 transition-colors last:border-0 hover:bg-gray-50"
            >
              <%!-- Bundle title + image --%>
              <td class="px-5 py-3.5">
                <.link navigate={~p"/admin/bundles/#{bundle}"} class="flex items-center gap-3">
                  <%= if bundle.image && bundle.image != "" do %>
                    <img
                      src={bundle.image}
                      alt={bundle.title}
                      class="h-10 w-10 flex-shrink-0 rounded-lg border border-gray-200 object-cover"
                    />
                  <% else %>
                    <div class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-gray-100 text-lg">
                      🎁
                    </div>
                  <% end %>
                  <span class="text-sm font-semibold text-gray-900">{bundle.title}</span>
                </.link>
              </td>

              <%!-- Description --%>
              <td class="px-5 py-3.5">
                <span class="line-clamp-1 max-w-xs text-sm text-gray-500">{bundle.description}</span>
              </td>

              <%!-- Status --%>
              <td class="px-5 py-3.5">
                <span class={[
                  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold",
                  if(bundle.is_active,
                    do: "bg-green-50 text-green-700",
                    else: "bg-gray-100 text-gray-500"
                  )
                ]}>
                  <span class={[
                    "h-1.5 w-1.5 rounded-full",
                    if(bundle.is_active, do: "bg-green-500", else: "bg-gray-400")
                  ]} />
                  {if bundle.is_active, do: "Active", else: "Inactive"}
                </span>
              </td>

              <%!-- Actions --%>
              <td class="px-5 py-3.5">
                <div class="flex items-center justify-end gap-1 opacity-0 transition-opacity group-hover:opacity-100">
                  <.link navigate={~p"/admin/bundles/#{bundle}"}>
                    <button class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
                      <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                        <circle cx="12" cy="12" r="3" />
                      </svg>
                    </button>
                  </.link>

                  <.link patch={~p"/admin/bundles/#{bundle}/edit"}>
                    <button class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
                      <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                      </svg>
                    </button>
                  </.link>

                  <button
                    phx-click={JS.push("delete", value: %{id: bundle.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this bundle?"
                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                  >
                    <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
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
      </div>

      <%!-- Empty state --%>
      <div
        :if={Enum.empty?(@streams.bundles.inserts)}
        class="flex flex-col items-center justify-center py-20 text-center"
      >
        <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-gray-100 text-3xl">
          🎁
        </div>
        <p class="mt-4 text-sm font-semibold text-gray-700">No bundles yet</p>
        <p class="mt-1 text-sm text-gray-400">Create your first bundle to get started.</p>
        <.link patch={~p"/admin/bundles/new"} class="mt-6">
          <button class="rounded-lg bg-gray-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-gray-700">
            New Bundle
          </button>
        </.link>
      </div>
    </div>

    <%!-- Modal --%>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="bundle-modal"
      show
      on_cancel={JS.patch(~p"/admin/bundles")}
    >
      <.live_component
        module={SheglowWeb.BundleLive.FormComponent}
        id={@bundle.id || :new}
        title={@page_title}
        action={@live_action}
        bundle={@bundle}
        patch={~p"/admin/bundles"}
      />
    </.modal>
    """
  end
end
