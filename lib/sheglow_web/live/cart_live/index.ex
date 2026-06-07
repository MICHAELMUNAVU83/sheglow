defmodule SheglowWeb.CartLive.Index do
  use SheglowWeb, :live_view
  import SheglowWeb.HomeComponents

  alias Sheglow.ProductVariants

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Your Cart | Sheglow")
     |> assign(:cart_items, [])
     |> assign(:cart_loaded, false)
     |> assign(:variants_by_product, %{})}
  end

  @impl true
  def handle_event("cart_loaded", %{"items" => items}, socket) do
    product_ids = items |> Enum.map(& &1["id"]) |> Enum.uniq() |> Enum.reject(&is_nil/1)
    variants_by_product = ProductVariants.list_variants_for_products(product_ids)

    {:noreply,
     socket
     |> assign(:cart_items, items)
     |> assign(:cart_loaded, true)
     |> assign(:variants_by_product, variants_by_product)}
  end

  @impl true
  def handle_event("remove_item", %{"key" => key}, socket) do
    {:noreply, push_event(socket, "remove-cart-item", %{key: key})}
  end

  @impl true
  def handle_event("update_quantity", %{"key" => key, "quantity" => qty}, socket) do
    qty = max(1, min(99, String.to_integer(to_string(qty))))
    {:noreply, push_event(socket, "update-cart-quantity", %{key: key, quantity: qty})}
  end

  @impl true
  def handle_event(
        "update_variant",
        %{
          "key" => key,
          "color" => color,
          "color_id" => color_id,
          "color_hex" => color_hex,
          "size" => size
        },
        socket
      ) do
    {:noreply,
     push_event(socket, "swap-cart-item", %{
       old_key: key,
       color: color,
       color_id: color_id,
       color_hex: color_hex,
       size: size
     })}
  end

  defp total_price(items) do
    Enum.reduce(items, 0, fn item, acc ->
      acc + (item["price"] || 0) * (item["quantity"] || 1)
    end)
  end

  defp fmt(n), do: SheglowWeb.Format.price(n)

  # Returns unique colors [{name, hex, id}] for a product from DB variants
  defp colors_for(variants_by_product, product_id) do
    (variants_by_product[product_id] || [])
    |> Enum.filter(&(&1.color_name not in [nil, ""]))
    |> Enum.uniq_by(& &1.color_name)
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} ->
      %{name: v.color_name, hex: v.color_hex || "#000000", id: "c#{idx + 1}"}
    end)
  end

  # Returns sizes available for a given color within a product's variants
  defp sizes_for(variants_by_product, product_id, color_name) do
    (variants_by_product[product_id] || [])
    |> Enum.filter(&(&1.color_name == color_name and &1.size not in [nil, ""]))
    |> Enum.map(& &1.size)
    |> Enum.uniq()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="cart-page" class="min-h-screen bg-white" phx-hook="CartSync">
      <.navbar cart_items={@cart_items} collections={[]} />

      <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <h1 class="mb-8 text-3xl font-bold text-gray-900">Your Cart</h1>

        <%= if not @cart_loaded do %>
          <div class="space-y-4">
            <%= for _ <- 1..3 do %>
              <div class="h-24 animate-pulse rounded-xl bg-gray-100"></div>
            <% end %>
          </div>
        <% else %>
          <%= if @cart_items == [] do %>
            <div class="flex flex-col items-center justify-center py-24 text-center">
              <svg
                class="h-20 w-20 text-gray-200"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1"
                  d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
              <h2 class="mt-6 text-xl font-semibold text-gray-800">Your cart is empty</h2>
              <p class="mt-2 text-gray-500">Start adding some beautiful pieces to your cart.</p>
              <a
                href="/"
                class="mt-8 rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
              >
                Shop Now
              </a>
            </div>
          <% else %>
            <div class="grid gap-8 lg:grid-cols-3">
              <%!-- Cart Items --%>
              <div class="lg:col-span-2 space-y-4">
                <%= for item <- @cart_items do %>
                  <% product_id = item["id"] %>
                  <% colors = colors_for(@variants_by_product, product_id) %>
                  <% current_color = item["color"] %>
                  <% sizes = sizes_for(@variants_by_product, product_id, current_color) %>

                  <div class="rounded-xl border border-gray-100 bg-white p-4 shadow-sm">
                    <div class="flex gap-4">
                      <%!-- Image --%>
                      <div class="h-28 w-24 flex-shrink-0 overflow-hidden rounded-lg bg-gray-100">
                        <%= if item["image"] do %>
                          <img
                            src={item["image"]}
                            alt={item["name"]}
                            class="h-full w-full object-cover object-top object-top"
                          />
                        <% else %>
                          <div class="flex h-full items-center justify-center text-3xl">👗</div>
                        <% end %>
                      </div>

                      <%!-- Details --%>
                      <div class="flex flex-1 flex-col gap-3">
                        <div class="flex items-start justify-between gap-2">
                          <h3 class="font-semibold text-gray-900 leading-snug">{item["name"]}</h3>
                          <button
                            phx-click="remove_item"
                            phx-value-key={item["key"]}
                            class="shrink-0 text-gray-300 transition hover:text-red-500"
                            aria-label="Remove"
                          >
                            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M6 18L18 6M6 6l12 12"
                              />
                            </svg>
                          </button>
                        </div>

                        <%!-- Variant selectors --%>
                        <div class="flex flex-wrap gap-4">
                          <%!-- Color --%>
                          <%= if colors != [] do %>
                            <div>
                              <p class="mb-1.5 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
                                Colour
                              </p>
                              <div class="flex flex-wrap gap-1.5">
                                <%= for c <- colors do %>
                                  <button
                                    type="button"
                                    title={c.name}
                                    phx-click="update_variant"
                                    phx-value-key={item["key"]}
                                    phx-value-color={c.name}
                                    phx-value-color_id={c.id}
                                    phx-value-color_hex={c.hex}
                                    phx-value-size={item["size"] || "M"}
                                    class={[
                                      "h-7 w-7 rounded-full border-2 transition",
                                      if(item["color"] == c.name,
                                        do: "border-gray-900 ring-2 ring-gray-900 ring-offset-1",
                                        else: "border-transparent hover:border-gray-400"
                                      )
                                    ]}
                                    style={"background-color: #{c.hex}"}
                                  />
                                <% end %>
                              </div>
                            </div>
                          <% end %>

                          <%!-- Size --%>
                          <%= if sizes != [] do %>
                            <div>
                              <p class="mb-1.5 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
                                Size
                              </p>
                              <div class="flex flex-wrap gap-1.5">
                                <%= for s <- sizes do %>
                                  <button
                                    type="button"
                                    phx-click="update_variant"
                                    phx-value-key={item["key"]}
                                    phx-value-color={item["color"] || ""}
                                    phx-value-color_id={item["color_id"] || ""}
                                    phx-value-color_hex={item["color_hex"] || ""}
                                    phx-value-size={s}
                                    class={[
                                      "rounded-md border px-2.5 py-1 text-xs font-medium transition",
                                      if(item["size"] == s,
                                        do: "border-gray-900 bg-gray-900 text-white",
                                        else: "border-gray-200 text-gray-600 hover:border-gray-400"
                                      )
                                    ]}
                                  >
                                    {s}
                                  </button>
                                <% end %>
                              </div>
                            </div>
                          <% else %>
                            <%!-- Fallback: show current color/size as read-only text --%>
                            <p class="text-sm text-gray-400">
                              {if item["color"], do: item["color"]}
                              {if item["size"], do: "· #{item["size"]}"}
                            </p>
                          <% end %>
                        </div>

                        <%!-- Qty + price row --%>
                        <div class="flex items-center justify-between">
                          <div class="flex items-center gap-2 rounded-full border border-gray-200 px-3 py-1">
                            <button
                              phx-click="update_quantity"
                              phx-value-key={item["key"]}
                              phx-value-quantity={max(1, (item["quantity"] || 1) - 1)}
                              class="text-gray-600 hover:text-black"
                            >
                              −
                            </button>
                            <span class="w-6 text-center text-sm font-medium">
                              {item["quantity"] || 1}
                            </span>
                            <button
                              phx-click="update_quantity"
                              phx-value-key={item["key"]}
                              phx-value-quantity={(item["quantity"] || 1) + 1}
                              class="text-gray-600 hover:text-black"
                            >
                              +
                            </button>
                          </div>
                          <span class="font-semibold text-gray-900">
                            UGX {fmt((item["price"] || 0) * (item["quantity"] || 1))}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>

              <%!-- Order Summary --%>
              <div class="h-fit rounded-xl border border-gray-100 bg-gray-50 p-6 shadow-sm">
                <h2 class="mb-6 text-lg font-semibold text-gray-900">Order Summary</h2>
                <div class="space-y-3 text-sm">
                  <div class="flex justify-between text-gray-600">
                    <span>
                      Subtotal ({Enum.reduce(@cart_items, 0, fn i, acc ->
                        acc + (i["quantity"] || 1)
                      end)} items)
                    </span>
                    <span>UGX {fmt(total_price(@cart_items))}</span>
                  </div>
                  <div class="flex justify-between text-gray-600">
                    <span>Shipping</span>
                    <span class="text-green-600">Free</span>
                  </div>
                  <div class="border-t border-gray-200 pt-3">
                    <div class="flex justify-between text-base font-semibold text-gray-900">
                      <span>Total</span>
                      <span>UGX {fmt(total_price(@cart_items))}</span>
                    </div>
                  </div>
                </div>
                <a
                  href="/checkout"
                  class="mt-6 block w-full rounded-full bg-[#C8001F] py-3 text-center text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
                >
                  Proceed to Checkout
                </a>
                <a
                  href="/"
                  class="mt-3 block text-center text-sm text-gray-500 underline-offset-2 hover:underline"
                >
                  Continue Shopping
                </a>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>

      <.footer />
    </div>
    """
  end
end
