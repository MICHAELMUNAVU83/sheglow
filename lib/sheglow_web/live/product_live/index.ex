defmodule SheglowWeb.ProductLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Products
  alias Sheglow.Products.Product
  alias Sheglow.Collections

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Products")
     |> assign(:current_path, "/admin/products")
     |> assign(:collections, Collections.list_collections())
     |> stream(:products, Products.list_products())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({SheglowWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)
    {:ok, _} = Products.delete_product(product)
    {:noreply, stream_delete(socket, :products, product)}
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
          <h1 class="mt-0.5 font-serif text-2xl font-bold">Products</h1>
        </div>
        <.link patch={~p"/admin/products/new"}>
          <button class="flex items-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-[#C8001F] transition hover:bg-red-50 shadow-sm">
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            New Product
          </button>
        </.link>
      </div>
    </div>

    <%!-- Table Card --%>
    <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
      <div class="border-b border-gray-100 px-5 py-4">
        <p class="font-serif text-sm font-semibold text-gray-700">All Products</p>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-gray-100 bg-gray-50/80">
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Product
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Price
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Badge
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Tags
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Status
              </th>
              <th class="px-5 py-3 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Pos
              </th>
              <th class="px-5 py-3 text-right text-[11px] font-semibold uppercase tracking-wider text-gray-400">
                Actions
              </th>
            </tr>
          </thead>

          <tbody id="products" phx-update="stream">
            <tr
              :for={{id, product} <- @streams.products}
              id={id}
              class="group border-b border-gray-100 transition-colors last:border-0 hover:bg-gray-50"
            >
              <%!-- Product name + slug --%>
              <td class="px-5 py-3.5">
                <.link navigate={~p"/admin/products/#{product}"} class="flex items-center gap-3">
                  <div class="h-10 w-10 flex-shrink-0 overflow-hidden rounded-lg bg-gray-100">
                    <%= if product.image not in [nil, ""] do %>
                      <img
                        src={product.image}
                        alt={product.name}
                        class="h-full w-full object-cover"
                      />
                    <% else %>
                      <div class="flex h-full w-full items-center justify-center text-base">👗</div>
                    <% end %>
                  </div>
                  <div>
                    <p class="text-sm font-semibold text-gray-900">{product.name}</p>
                    <p class="text-xs text-gray-400">{product.slug}</p>
                  </div>
                </.link>
              </td>

              <%!-- Price --%>
              <td class="px-5 py-3.5">
                <span class="text-sm font-semibold text-gray-900">
                  UGX {SheglowWeb.Format.price(product.base_price)}
                </span>
              </td>

              <%!-- Badge --%>
              <td class="px-5 py-3.5">
                <%= if product.badge_label not in [nil, ""] do %>
                  <span
                    class="inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold text-white"
                    style={"background-color: #{product.badge_color || "#6b7280"}"}
                  >
                    {product.badge_label}
                  </span>
                <% else %>
                  <span class="text-xs text-gray-300">—</span>
                <% end %>
              </td>

              <%!-- Tags: featured / bestseller / new arrival --%>
              <td class="px-5 py-3.5">
                <div class="flex flex-wrap gap-1">
                  <%= if product.is_featured do %>
                    <span class="rounded-full bg-purple-50 px-2 py-0.5 text-[10px] font-semibold text-purple-600">
                      Featured
                    </span>
                  <% end %>
                  <%= if product.is_bestseller do %>
                    <span class="rounded-full bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-600">
                      Bestseller
                    </span>
                  <% end %>
                  <%= if product.is_new_arrival do %>
                    <span class="rounded-full bg-blue-50 px-2 py-0.5 text-[10px] font-semibold text-blue-600">
                      New
                    </span>
                  <% end %>
                  <%= if not product.is_featured and not product.is_bestseller and not product.is_new_arrival do %>
                    <span class="text-xs text-gray-300">—</span>
                  <% end %>
                </div>
              </td>

              <%!-- Status --%>
              <td class="px-5 py-3.5">
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
              <td class="px-5 py-3.5">
                <span class="text-sm text-gray-500">{product.position}</span>
              </td>

              <%!-- Actions --%>
              <td class="px-5 py-3.5">
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

                  <button
                    phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
                    data-confirm="Are you sure you want to delete this product?"
                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
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
      </div>

      <%!-- Empty state --%>
      <div
        :if={Enum.empty?(@streams.products.inserts)}
        class="flex flex-col items-center justify-center py-20 text-center"
      >
        <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-gray-100">
          <svg
            class="h-6 w-6 text-gray-400"
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
        <p class="mt-4 text-sm font-semibold text-gray-700">No products yet</p>
        <p class="mt-1 text-sm text-gray-400">Add your first product to get started.</p>
        <.link patch={~p"/admin/products/new"} class="mt-6">
          <button class="rounded-xl bg-[#C8001F] px-4 py-2 text-sm font-semibold text-white transition hover:bg-[#a8001a]">
            New Product
          </button>
        </.link>
      </div>
    </div>

    <%!-- Modal --%>
    <.modal
      :if={@live_action in [:new, :edit]}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/admin/products")}
    >
      <.live_component
        module={SheglowWeb.ProductLive.FormComponent}
        id={@product.id || :new}
        title={@page_title}
        action={@live_action}
        product={@product}
        collections={@collections}
        patch={~p"/admin/products"}
      />
    </.modal>
    """
  end
end
