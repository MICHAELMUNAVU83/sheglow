defmodule SheglowWeb.CollectionLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Collections
  alias Sheglow.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Collection")
     |> assign(:current_path, "/admin/collections")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    collection = Collections.get_collection!(id)

    {:noreply,
     socket
     |> assign(:page_title, collection.title)
     |> assign(:collection, collection)
     |> assign(:products, Products.list_products_for_collection(id))}
  end

  @impl true
  def handle_info({SheglowWeb.CollectionLive.FormComponent, {:saved, collection}}, socket) do
    {:noreply, assign(socket, :collection, collection)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page header --%>
    <div class="mb-8 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/collections"}>
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
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Collections</p>
          <h1 class="mt-0.5 text-3xl font-bold text-gray-900">{@collection.title}</h1>
        </div>
      </div>

      <.link patch={~p"/admin/collections/#{@collection}/show/edit"}>
        <button class="flex items-center gap-2 rounded-xl bg-gray-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-gray-700">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
          </svg>
          Edit Collection
        </button>
      </.link>
    </div>

    <%!-- Collection summary card --%>
    <div class="mb-8 overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex gap-8 p-8">
        <%!-- Cover image --%>
        <div class="flex-shrink-0">
          <%= if @collection.image && @collection.image != "" do %>
            <img
              src={@collection.image}
              alt={@collection.title}
              class="h-48 w-48 rounded-2xl border border-gray-200 object-cover object-top shadow-sm"
            />
          <% else %>
            <div class="flex h-48 w-48 items-center justify-center rounded-2xl border border-gray-200 bg-gray-50 text-5xl">
              🗂️
            </div>
          <% end %>
        </div>

        <%!-- Details --%>
        <div class="min-w-0 flex-1 py-1">
          <div class="flex flex-wrap items-start justify-between gap-3">
            <div>
              <h2 class="text-2xl font-bold text-gray-900">{@collection.title}</h2>
              <div class="mt-1 flex items-center gap-2">
                <code class="text-sm text-gray-400">/collections/{@collection.slug}</code>
              </div>
            </div>

            <span class={[
              "inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-xs font-semibold",
              if(@collection.is_active,
                do: "bg-green-50 text-green-700",
                else: "bg-gray-100 text-gray-500"
              )
            ]}>
              <span class={[
                "h-2 w-2 rounded-full",
                if(@collection.is_active, do: "bg-green-500", else: "bg-gray-400")
              ]} />
              {if @collection.is_active, do: "Active", else: "Inactive"}
            </span>
          </div>

          <div class="mt-6 flex flex-wrap gap-6">
            <div>
              <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Position</p>
              <p class="mt-1 text-base font-semibold text-gray-900">{@collection.position}</p>
            </div>
            <div>
              <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Products</p>
              <p class="mt-1 text-base font-semibold text-gray-900">{length(@products)}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <%!-- Products in collection --%>
    <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
        <p class="text-base font-semibold text-gray-700">
          Products
          <span class="ml-2 rounded-full bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-500">
            {length(@products)}
          </span>
        </p>
        <.link patch={~p"/admin/products/new"}>
          <button class="flex items-center gap-2 rounded-xl border border-gray-200 px-4 py-2 text-sm font-semibold text-gray-600 transition hover:border-gray-300 hover:text-gray-900">
            <svg
              class="h-4 w-4"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            Add Product
          </button>
        </.link>
      </div>

      <%= if Enum.empty?(@products) do %>
        <div class="flex flex-col items-center justify-center py-20 text-center">
          <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100">
            <svg
              class="h-7 w-7 text-gray-400"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"
              />
              <line x1="7" y1="7" x2="7.01" y2="7" />
            </svg>
          </div>
          <p class="mt-4 text-base font-semibold text-gray-700">No products in this collection</p>
          <p class="mt-1.5 text-sm text-gray-400">
            Add a product and assign it to <span class="font-medium text-gray-600">{@collection.title}</span>.
          </p>
          <.link patch={~p"/admin/products/new"} class="mt-6">
            <button class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700">
              Add Product
            </button>
          </.link>
        </div>
      <% else %>
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead>
              <tr class="border-b border-gray-100 bg-gray-50">
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Product
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Price
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Badge
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Tags
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Status
                </th>
                <th class="px-6 py-3.5 text-left text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Pos
                </th>
                <th class="px-6 py-3.5 text-right text-xs font-semibold uppercase tracking-wider text-gray-400">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                :for={product <- @products}
                class="group border-b border-gray-100 transition-colors last:border-0 hover:bg-gray-50"
              >
                <%!-- Product name + image --%>
                <td class="px-6 py-4">
                  <.link navigate={~p"/admin/products/#{product}"} class="flex items-center gap-3">
                    <%= if product.image && product.image != "" do %>
                      <img
                        src={product.image}
                        alt={product.name}
                        class="h-11 w-11 flex-shrink-0 rounded-xl border border-gray-200 object-cover"
                      />
                    <% else %>
                      <div class="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-gray-100 text-xl">
                        👗
                      </div>
                    <% end %>
                    <div>
                      <p class="text-sm font-semibold text-gray-900">{product.name}</p>
                      <p class="text-xs text-gray-400">{product.slug}</p>
                    </div>
                  </.link>
                </td>

                <%!-- Price --%>
                <td class="px-6 py-4">
                  <span class="text-sm font-semibold text-gray-900">
                    UGX {SheglowWeb.Format.price(product.base_price)}
                  </span>
                </td>

                <%!-- Badge --%>
                <td class="px-6 py-4">
                  <%= if product.badge_label not in [nil, ""] do %>
                    <span
                      class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold"
                      style={"background-color: #{product.badge_color || "#6b7280"}; color: #fff"}
                    >
                      {product.badge_label}
                    </span>
                  <% else %>
                    <span class="text-xs text-gray-300">—</span>
                  <% end %>
                </td>

                <%!-- Tags --%>
                <td class="px-6 py-4">
                  <div class="flex flex-wrap gap-1">
                    <%= if product.is_featured do %>
                      <span class="rounded-full bg-purple-600 px-2 py-0.5 text-[10px] font-semibold text-white">
                        Featured
                      </span>
                    <% end %>
                    <%= if product.is_bestseller do %>
                      <span class="rounded-full bg-amber-500 px-2 py-0.5 text-[10px] font-semibold text-white">
                        Bestseller
                      </span>
                    <% end %>
                    <%= if product.is_new_arrival do %>
                      <span class="rounded-full bg-blue-500 px-2 py-0.5 text-[10px] font-semibold text-white">
                        New
                      </span>
                    <% end %>
                    <%= if not product.is_featured and not product.is_bestseller and not product.is_new_arrival do %>
                      <span class="text-xs text-gray-300">—</span>
                    <% end %>
                  </div>
                </td>

                <%!-- Status --%>
                <td class="px-6 py-4">
                  <span class={[
                    "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold capitalize",
                    case product.status do
                      "active" -> "bg-green-50 text-green-700"
                      "draft" -> "bg-gray-100 text-gray-500"
                      _ -> "bg-gray-100 text-gray-500"
                    end
                  ]}>
                    <span class={[
                      "h-1.5 w-1.5 rounded-full",
                      case product.status do
                        "active" -> "bg-green-500"
                        _ -> "bg-gray-400"
                      end
                    ]} />
                    {product.status || "draft"}
                  </span>
                </td>

                <%!-- Position --%>
                <td class="px-6 py-4">
                  <span class="text-sm text-gray-500">{product.position}</span>
                </td>

                <%!-- Actions --%>
                <td class="px-6 py-4">
                  <div class="flex items-center justify-end gap-1 opacity-0 transition-opacity group-hover:opacity-100">
                    <.link navigate={~p"/admin/products/#{product}"}>
                      <button class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
                        <svg
                          class="h-3.5 w-3.5"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="2"
                        >
                          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                          <circle cx="12" cy="12" r="3" />
                        </svg>
                      </button>
                    </.link>
                    <.link patch={~p"/admin/products/#{product}/edit"}>
                      <button class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
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
                    </.link>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      <% end %>
    </div>

    <%!-- Edit modal --%>
    <.modal
      :if={@live_action == :edit}
      id="collection-modal"
      show
      on_cancel={JS.patch(~p"/admin/collections/#{@collection}")}
    >
      <.live_component
        module={SheglowWeb.CollectionLive.FormComponent}
        id={@collection.id}
        title="Edit Collection"
        action={@live_action}
        collection={@collection}
        patch={~p"/admin/collections/#{@collection}"}
      />
    </.modal>
    """
  end
end
