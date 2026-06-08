defmodule SheglowWeb.CustomerLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Customers
  alias Sheglow.Orders

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Customer")
     |> assign(:current_path, "/admin/customers")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    customer = Customers.get_customer!(id)
    orders = Customers.list_all_orders_for_customer(customer.email)

    # Flatten all items across all orders and deduplicate by product id
    all_products =
      orders
      |> Enum.flat_map(fn o -> o.items || [] end)
      |> Enum.group_by(fn item -> item["id"] end)
      |> Enum.map(fn {_id, items} ->
        first = List.first(items)
        total_qty = Enum.reduce(items, 0, fn i, acc -> acc + (i["quantity"] || 1) end)
        Map.put(first, "total_ordered", total_qty)
      end)
      |> Enum.sort_by(fn i -> -i["total_ordered"] end)

    {:noreply,
     socket
     |> assign(:page_title, customer.name)
     |> assign(:customer, customer)
     |> assign(:orders, orders)
     |> assign(:all_products, all_products)
     |> assign(:counts, %{pending_orders: Orders.count_pending()})}
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp fmt(n), do: SheglowWeb.Format.price(n)

  defp format_date(dt) do
    Calendar.strftime(dt, "%d %b %Y, %H:%M")
  end

  defp format_day(dt) do
    Calendar.strftime(dt, "%d %b %Y")
  end

  defp status_color(status) do
    case status do
      "paid"       -> "bg-[#C8001F]/10 text-[#C8001F]"
      "processing" -> "bg-pink-50 text-pink-700"
      "shipped"    -> "bg-indigo-50 text-indigo-600"
      "delivered"  -> "bg-green-50 text-green-700"
      "cancelled"  -> "bg-gray-100 text-gray-500"
      "failed"     -> "bg-red-50 text-red-400"
      _            -> "bg-gray-100 text-gray-500"
    end
  end

  defp status_dot(status) do
    case status do
      "paid"       -> "bg-[#C8001F]"
      "processing" -> "bg-pink-500"
      "shipped"    -> "bg-indigo-500"
      "delivered"  -> "bg-green-500"
      "cancelled"  -> "bg-gray-400"
      "failed"     -> "bg-red-400"
      _            -> "bg-gray-400"
    end
  end

  defp avatar_color(email) when is_binary(email) do
    colors = [
      "bg-violet-500", "bg-blue-500", "bg-green-500", "bg-amber-500",
      "bg-rose-500", "bg-indigo-500", "bg-teal-500", "bg-orange-500"
    ]

    idx = :erlang.phash2(email, length(colors))
    Enum.at(colors, idx)
  end

  defp avatar_color(_), do: "bg-gray-400"

  defp initials(name) when is_binary(name) and name != "" do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp initials(_), do: "?"

  defp item_count(items) when is_list(items) do
    Enum.reduce(items, 0, fn i, acc -> acc + (i["quantity"] || 1) end)
  end

  defp item_count(_), do: 0

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">

      <!-- ── Hero banner ── -->
      <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#C8001F] to-[#8b0014] px-7 py-6 text-white shadow-md">
        <div class="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-white/5"></div>
        <div class="flex items-center gap-4">
          <.link navigate="/admin/customers"
            class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-white/10 text-white backdrop-blur-sm transition hover:bg-white/20">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </.link>
          <div class={["flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full text-lg font-bold text-white ring-2 ring-white/30 shadow-md", avatar_color(@customer.email)]}>
            {initials(@customer.name)}
          </div>
          <div>
            <p class="text-xs font-medium uppercase tracking-widest text-red-200">Customer</p>
            <h1 class="mt-0.5 font-serif text-xl font-bold">{@customer.name}</h1>
            <p class="text-xs text-red-200">{@customer.email}</p>
          </div>
        </div>
      </div>

      <!-- Stat strip -->
      <div class="grid grid-cols-3 gap-4">
        <div class="overflow-hidden rounded-3xl border border-[#C8001F]/20 bg-[#C8001F]/5 p-5">
          <p class="text-xs font-semibold uppercase tracking-widest text-[#C8001F]/70">Total Spent</p>
          <p class="mt-2 font-serif text-2xl font-bold text-[#C8001F]">UGX {fmt(@customer.total_spent)}</p>
        </div>
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white p-5 shadow-sm">
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Paid Orders</p>
          <p class="mt-2 font-serif text-2xl font-bold text-gray-900">{@customer.order_count}</p>
        </div>
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white p-5 shadow-sm">
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Products Bought</p>
          <p class="mt-2 font-serif text-2xl font-bold text-gray-900">{length(@all_products)}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">

        <!-- Left: Products + Orders timeline -->
        <div class="space-y-6 lg:col-span-2">

          <!-- Products bought -->
          <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-5">
              <h2 class="font-serif text-base font-semibold text-gray-900">
                Products Bought
                <span class="ml-1.5 rounded-full bg-[#C8001F]/10 px-2 py-0.5 text-xs font-bold text-[#C8001F]">{length(@all_products)}</span>
              </h2>
            </div>
            <%= if @all_products == [] do %>
              <div class="py-10 text-center text-sm text-gray-400">No products yet.</div>
            <% else %>
              <div class="divide-y divide-gray-100">
                <%= for item <- @all_products do %>
                  <div class="flex items-center gap-4 px-6 py-3.5">
                    <!-- Thumbnail -->
                    <div class="h-14 w-12 flex-shrink-0 overflow-hidden rounded-xl bg-gray-100">
                      <%= if item["image"] do %>
                        <img src={item["image"]} alt={item["name"]} class="h-full w-full object-cover" />
                      <% else %>
                        <div class="flex h-full items-center justify-center text-xl">👗</div>
                      <% end %>
                    </div>
                    <!-- Details -->
                    <div class="min-w-0 flex-1">
                      <p class="truncate text-sm font-semibold text-gray-900">{item["name"]}</p>
                      <% attrs = [item["color"], item["size"]] |> Enum.filter(&(&1 not in [nil, ""])) %>
                      <%= if attrs != [] do %>
                        <p class="text-xs text-gray-400">{Enum.join(attrs, " · ")}</p>
                      <% end %>
                    </div>
                    <!-- Total ordered -->
                    <div class="text-right">
                      <span class="rounded-full bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-700">
                        ×{item["total_ordered"]}
                      </span>
                      <p class="mt-1 text-xs font-semibold text-gray-900">
                        UGX {fmt((item["price"] || 0) * item["total_ordered"])}
                      </p>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- Order history -->
          <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-6 py-5">
              <h2 class="font-serif text-base font-semibold text-gray-900">
                Order History
                <span class="ml-1.5 rounded-full bg-gray-100 px-2 py-0.5 text-xs font-bold text-gray-500">{length(@orders)}</span>
              </h2>
            </div>
            <%= if @orders == [] do %>
              <div class="py-10 text-center text-sm text-gray-400">No orders yet.</div>
            <% else %>
              <div class="divide-y divide-gray-100">
                <%= for order <- @orders do %>
                  <div class="flex items-center gap-4 px-6 py-4">
                    <div class="min-w-0 flex-1">
                      <div class="flex items-center gap-3">
                        <span class="font-mono text-xs font-bold text-gray-900">{order.reference}</span>
                        <span class={[
                          "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-semibold capitalize",
                          status_color(order.status)
                        ]}>
                          <span class={["h-1.5 w-1.5 rounded-full", status_dot(order.status)]} />
                          {order.status}
                        </span>
                      </div>
                      <p class="mt-1 text-xs text-gray-400">
                        {item_count(order.items)} items · {format_date(order.inserted_at)}
                      </p>
                    </div>
                    <div class="text-right">
                      <p class="text-sm font-bold text-gray-900">UGX {fmt(order.total_amount)}</p>
                    </div>
                    <.link
                      navigate={"/admin/orders/#{order.id}"}
                      class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700"
                    >
                      <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                      </svg>
                    </.link>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

        </div>

        <!-- Right: Customer info -->
        <div>
          <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
            <div class="border-b border-gray-100 px-5 py-5">
              <h2 class="font-serif text-base font-semibold text-gray-900">Contact Info</h2>
            </div>
            <div class="px-5 py-4 space-y-3 text-sm">
              <div>
                <p class="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-1">Email</p>
                <a href={"mailto:#{@customer.email}"} class="font-medium text-[#C8001F] hover:underline break-all">
                  {@customer.email}
                </a>
              </div>
              <%= if @customer.phone not in [nil, ""] do %>
                <div>
                  <p class="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-1">Phone</p>
                  <p class="font-medium text-gray-900">{@customer.phone}</p>
                </div>
              <% end %>
              <%= if @customer.address not in [nil, ""] do %>
                <div>
                  <p class="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-1">Address</p>
                  <p class="font-medium text-gray-900">{@customer.address}</p>
                </div>
              <% end %>
              <div>
                <p class="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-1">Customer Since</p>
                <p class="font-medium text-gray-900">{format_day(@customer.inserted_at)}</p>
              </div>
            </div>
          </div>
        </div>

      </div>

    </div>
    """
  end
end
