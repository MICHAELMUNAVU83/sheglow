defmodule SheglowWeb.BundleLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Bundles
  alias Sheglow.BundleItems
  alias Sheglow.BundleItems.BundleItem
  alias Sheglow.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Bundle")
     |> assign(:current_path, "/admin/bundles")
     |> assign(:show_item_form, false)
     |> assign(:item_error, nil)
     |> assign(:item_changeset, BundleItems.change_bundle_item(%BundleItem{}))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    bundle = Bundles.get_bundle!(id)

    {:noreply,
     socket
     |> assign(:page_title, bundle.title)
     |> assign(:bundle, bundle)
     |> assign(:bundle_items, BundleItems.list_bundle_items_for_bundle(id))
     |> assign(:all_products, Products.list_products())}
  end

  @impl true
  def handle_info({SheglowWeb.BundleLive.FormComponent, {:saved, bundle}}, socket) do
    {:noreply, assign(socket, :bundle, bundle)}
  end

  # ── Bundle items ──────────────────────────────────────────────────

  @impl true
  def handle_event("toggle_item_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_item_form, !socket.assigns.show_item_form)
     |> assign(:item_error, nil)}
  end

  @impl true
  def handle_event("save_item", %{"bundle_item" => params}, socket) do
    if params["product_id"] in [nil, ""] do
      {:noreply, assign(socket, :item_error, "Please select a product.")}
    else
      params =
        params
        |> Map.put("bundle_id", socket.assigns.bundle.id)

      case BundleItems.create_bundle_item(params) do
        {:ok, _item} ->
          {:noreply,
           socket
           |> assign(
             :bundle_items,
             BundleItems.list_bundle_items_for_bundle(socket.assigns.bundle.id)
           )
           |> assign(:show_item_form, false)
           |> assign(:item_error, nil)
           |> assign(:item_changeset, BundleItems.change_bundle_item(%BundleItem{}))}

        {:error, %{errors: errors}} ->
          msg =
            cond do
              Keyword.has_key?(errors, :bundle_id) and Keyword.has_key?(errors, :product_id) ->
                "Please select a product."

              Keyword.has_key?(errors, :product_id) ->
                "Please select a product."

              match?([{:bundle_id, _} | _], errors) ->
                "Something went wrong. Please try again."

              true ->
                "This product is already in the bundle."
            end

          {:noreply, assign(socket, :item_error, msg)}
      end
    end
  end

  @impl true
  def handle_event("delete_item", %{"id" => id}, socket) do
    item = BundleItems.get_bundle_item!(id)
    {:ok, _} = BundleItems.delete_bundle_item(item)

    {:noreply,
     assign(
       socket,
       :bundle_items,
       BundleItems.list_bundle_items_for_bundle(socket.assigns.bundle.id)
     )}
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp already_added?(bundle_items, product_id) do
    Enum.any?(bundle_items, &(&1.product_id == product_id))
  end

  # ── Render ────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page header --%>
    <div class="mb-8 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/bundles"}>
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
          <h1 class="mt-0.5 text-3xl font-bold text-gray-900">{@bundle.title}</h1>
        </div>
      </div>

      <.link patch={~p"/admin/bundles/#{@bundle}/show/edit"}>
        <button class="flex items-center gap-2 rounded-xl bg-gray-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-gray-700">
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
          </svg>
          Edit Bundle
        </button>
      </.link>
    </div>

    <%!-- Bundle summary card --%>
    <div class="mb-8 overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex gap-8 p-8">
        <%!-- Image --%>
        <div class="flex-shrink-0">
          <%= if @bundle.image && @bundle.image != "" do %>
            <img
              src={@bundle.image}
              alt={@bundle.title}
              class="h-48 w-48 rounded-2xl border border-gray-200 object-cover object-top shadow-sm"
            />
          <% else %>
            <div class="flex h-48 w-48 items-center justify-center rounded-2xl border border-gray-200 bg-gray-50 text-6xl">
              🎁
            </div>
          <% end %>
        </div>

        <%!-- Details --%>
        <div class="min-w-0 flex-1 py-1">
          <div class="flex flex-wrap items-start justify-between gap-3">
            <h2 class="text-2xl font-bold text-gray-900">{@bundle.title}</h2>

            <span class={[
              "inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 text-xs font-semibold",
              if(@bundle.is_active,
                do: "bg-green-50 text-green-700",
                else: "bg-gray-100 text-gray-500"
              )
            ]}>
              <span class={[
                "h-2 w-2 rounded-full",
                if(@bundle.is_active, do: "bg-green-500", else: "bg-gray-400")
              ]} />
              {if @bundle.is_active, do: "Active", else: "Inactive"}
            </span>
          </div>

          <p class="mt-4 text-base text-gray-600">{@bundle.description}</p>

          <div class="mt-6">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">
              Items in Bundle
            </p>
            <p class="mt-1 text-2xl font-bold text-gray-900">{length(@bundle_items)}</p>
          </div>
        </div>
      </div>
    </div>

    <%!-- Bundle items panel --%>
    <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
        <p class="text-base font-semibold text-gray-700">
          Bundle Items
          <span class="ml-2 rounded-full bg-gray-100 px-2.5 py-0.5 text-sm font-medium text-gray-500">
            {length(@bundle_items)}
          </span>
        </p>
        <button
          type="button"
          phx-click="toggle_item_form"
          class={[
            "flex items-center gap-2 rounded-xl border px-4 py-2 text-sm font-semibold transition",
            if(@show_item_form,
              do: "border-gray-300 bg-gray-100 text-gray-700",
              else: "border-gray-200 text-gray-600 hover:border-gray-300 hover:text-gray-900"
            )
          ]}
        >
          <%= if @show_item_form do %>
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
            Add Product
          <% end %>
        </button>
      </div>

      <%!-- Add item form --%>
      <%= if @show_item_form do %>
        <div class="border-b border-gray-100 bg-gray-50 px-6 py-6">
          <p class="mb-4 text-xs font-semibold uppercase tracking-widest text-gray-400">
            Add Product to Bundle
          </p>

          <%= if Enum.empty?(@all_products) do %>
            <p class="text-sm text-gray-500">No products found. Create a product first.</p>
          <% else %>
            <form phx-submit="save_item" class="space-y-3">
              <div>
                <label class="mb-1.5 block text-sm font-semibold text-gray-700">Select Product</label>
                <select
                  name="bundle_item[product_id]"
                  class={[
                    "w-full rounded-xl border bg-white px-3.5 py-2.5 text-sm text-gray-900 transition focus:outline-none focus:ring-0",
                    if(@item_error,
                      do: "border-red-300 focus:border-red-400",
                      else: "border-gray-200 focus:border-gray-400"
                    )
                  ]}
                >
                  <option value="">— Choose a product —</option>
                  <%= for product <- @all_products do %>
                    <option value={product.id} disabled={already_added?(@bundle_items, product.id)}>
                      {product.name}{if already_added?(@bundle_items, product.id),
                        do: " (already in bundle)"}
                    </option>
                  <% end %>
                </select>
                <%= if @item_error do %>
                  <p class="mt-1.5 flex items-center gap-1.5 text-sm text-red-500">
                    <svg class="h-3.5 w-3.5 flex-shrink-0" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
                    </svg>
                    {@item_error}
                  </p>
                <% end %>
              </div>

              <div class="flex justify-end">
                <button
                  type="submit"
                  phx-disable-with="Adding..."
                  class="rounded-xl bg-gray-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-gray-700"
                >
                  Add to Bundle
                </button>
              </div>
            </form>
          <% end %>
        </div>
      <% end %>

      <%!-- Items list --%>
      <%= if Enum.empty?(@bundle_items) do %>
        <div class="flex flex-col items-center justify-center py-20 text-center">
          <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100 text-3xl">
            🎁
          </div>
          <p class="mt-4 text-base font-semibold text-gray-700">No products in this bundle</p>
          <p class="mt-1.5 text-sm text-gray-400">
            Use the "Add Product" button above to build this bundle.
          </p>
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
                  Status
                </th>
                <th class="px-6 py-3.5 text-right text-xs font-semibold uppercase tracking-wider text-gray-400">
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                :for={item <- @bundle_items}
                class="group border-b border-gray-100 last:border-0 hover:bg-gray-50"
              >
                <%!-- Product --%>
                <td class="px-6 py-4">
                  <.link
                    navigate={~p"/admin/products/#{item.product_id}"}
                    class="flex items-center gap-3"
                  >
                    <%= if item.product.image && item.product.image != "" do %>
                      <img
                        src={item.product.image}
                        alt={item.product.name}
                        class="h-11 w-11 flex-shrink-0 rounded-xl border border-gray-200 object-cover"
                      />
                    <% else %>
                      <div class="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-gray-100 text-xl">
                        👗
                      </div>
                    <% end %>
                    <div>
                      <p class="text-sm font-semibold text-gray-900">{item.product.name}</p>
                      <p class="text-xs text-gray-400">{item.product.slug}</p>
                    </div>
                  </.link>
                </td>

                <%!-- Price --%>
                <td class="px-6 py-4">
                  <span class="text-sm font-semibold text-gray-900">
                    Ksh {item.product.base_price}
                  </span>
                </td>

                <%!-- Status --%>
                <td class="px-6 py-4">
                  <span class={[
                    "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold capitalize",
                    case item.product.status do
                      "active" -> "bg-green-50 text-green-700"
                      _ -> "bg-gray-100 text-gray-500"
                    end
                  ]}>
                    <span class={[
                      "h-1.5 w-1.5 rounded-full",
                      case item.product.status do
                        "active" -> "bg-green-500"
                        _ -> "bg-gray-400"
                      end
                    ]} />
                    {item.product.status || "draft"}
                  </span>
                </td>

                <%!-- Remove --%>
                <td class="px-6 py-4 text-right">
                  <button
                    phx-click="delete_item"
                    phx-value-id={item.id}
                    data-confirm="Remove this product from the bundle?"
                    class="ml-auto flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 opacity-0 transition group-hover:opacity-100 hover:border-red-200 hover:bg-red-50 hover:text-red-500"
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
      id="bundle-modal"
      show
      on_cancel={JS.patch(~p"/admin/bundles/#{@bundle}")}
    >
      <.live_component
        module={SheglowWeb.BundleLive.FormComponent}
        id={@bundle.id}
        title="Edit Bundle"
        action={@live_action}
        bundle={@bundle}
        patch={~p"/admin/bundles/#{@bundle}"}
      />
    </.modal>
    """
  end
end
