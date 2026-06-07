defmodule SheglowWeb.DashboardLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Orders
  alias Sheglow.Customers
  alias Sheglow.Repo
  alias Sheglow.Products.Product
  alias Sheglow.Collections.Collection

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:current_path, "/admin")
     |> load_stats()
     |> load_charts()}
  end

  # ── Data loading ──────────────────────────────────────────────────────────

  defp load_stats(socket) do
    status_counts = Orders.count_by_status()

    socket
    |> assign(:total_revenue, Orders.total_revenue())
    |> assign(:total_orders, Orders.total_orders())
    |> assign(:total_customers, Customers.count_customers())
    |> assign(:avg_order_value, Orders.average_order_value())
    |> assign(:total_products, Repo.aggregate(Product, :count))
    |> assign(:total_collections, Repo.aggregate(Collection, :count))
    |> assign(:status_counts, status_counts)
    |> assign(:recent_orders, Orders.recent_orders(5))
  end

  defp load_charts(socket) do
    daily = Orders.daily_revenue(30)
    top_products = Orders.top_products_by_revenue(6)
    status_counts = socket.assigns.status_counts

    socket
    |> assign(:revenue_chart, build_revenue_chart(daily))
    |> assign(:status_chart, build_status_chart(status_counts))
    |> assign(:top_products_chart, build_top_products_chart(top_products))
  end

  # ── Chart builders ────────────────────────────────────────────────────────

  defp build_revenue_chart(daily) do
    labels = Enum.map(daily, fn {d, _} -> Calendar.strftime(d, "%d %b") end)
    values = Enum.map(daily, fn {_, v} -> v end)

    %{
      data: %{
        labels: labels,
        datasets: [
          %{
            label: "Revenue",
            data: values,
            borderColor: "#C8001F",
            backgroundColor: "rgba(200,0,31,0.08)",
            fill: true,
            tension: 0.45,
            pointRadius: 0,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "#C8001F",
            borderWidth: 2.5
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        interaction: %{mode: "index", intersect: false},
        plugins: %{
          legend: %{display: false},
          tooltip: %{
            backgroundColor: "#1a1a1a",
            titleFont: %{size: 11},
            bodyFont: %{size: 12, weight: "bold"},
            padding: 10,
            cornerRadius: 8
          }
        },
        scales: %{
          x: %{
            grid: %{display: false},
            border: %{display: false},
            ticks: %{font: %{size: 10}, color: "#9ca3af", maxTicksLimit: 7}
          },
          y: %{
            grid: %{color: "#f3f4f6"},
            border: %{display: false, dash: [4, 4]},
            ticks: %{font: %{size: 10}, color: "#9ca3af"},
            beginAtZero: true
          }
        }
      }
    }
    |> Jason.encode!()
  end

  defp build_status_chart(status_counts) do
    statuses = ~w(paid processing shipped delivered cancelled failed)
    labels = Enum.map(statuses, &String.capitalize/1)
    values = Enum.map(statuses, &Map.get(status_counts, &1, 0))

    colors = %{
      "paid" => "#C8001F",
      "processing" => "#e879a0",
      "shipped" => "#f9a8c9",
      "delivered" => "#86efac",
      "cancelled" => "#d1d5db",
      "failed" => "#fca5a5"
    }

    %{
      data: %{
        labels: labels,
        datasets: [
          %{
            data: values,
            backgroundColor: Enum.map(statuses, &Map.get(colors, &1, "#e5e7eb")),
            borderWidth: 0,
            hoverOffset: 8,
            borderRadius: 4
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        cutout: "72%",
        plugins: %{
          legend: %{
            display: true,
            position: "bottom",
            labels: %{boxWidth: 8, boxHeight: 8, padding: 12, font: %{size: 11}, color: "#6b7280"}
          },
          tooltip: %{
            backgroundColor: "#1a1a1a",
            padding: 10,
            cornerRadius: 8
          }
        }
      }
    }
    |> Jason.encode!()
  end

  defp build_top_products_chart(products) do
    labels = Enum.map(products, & &1.name)
    values = Enum.map(products, & &1.revenue)

    %{
      data: %{
        labels: labels,
        datasets: [
          %{
            label: "Revenue",
            data: values,
            backgroundColor: [
              "#C8001F",
              "#d4174e",
              "#e03070",
              "#e8588e",
              "#ef7faa",
              "#f5a6c5",
              "#f9c9de",
              "#fde8f0"
            ],
            borderRadius: 6,
            barThickness: 16
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: "y",
        plugins: %{
          legend: %{display: false},
          tooltip: %{
            backgroundColor: "#1a1a1a",
            padding: 10,
            cornerRadius: 8
          }
        },
        scales: %{
          x: %{
            grid: %{color: "#f3f4f6"},
            border: %{display: false},
            ticks: %{font: %{size: 10}, color: "#9ca3af"}
          },
          y: %{
            grid: %{display: false},
            border: %{display: false},
            ticks: %{font: %{size: 11}, color: "#374151"}
          }
        }
      }
    }
    |> Jason.encode!()
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp fmt(n), do: SheglowWeb.Format.price(n)

  defp status_pill(status) do
    case status do
      "paid" -> "bg-red-50 text-[#C8001F]"
      "processing" -> "bg-pink-50 text-pink-700"
      "shipped" -> "bg-indigo-50 text-indigo-600"
      "delivered" -> "bg-green-50 text-green-700"
      "cancelled" -> "bg-gray-100 text-gray-500"
      "failed" -> "bg-red-50 text-red-400"
      _ -> "bg-gray-100 text-gray-500"
    end
  end

  defp status_dot(status) do
    case status do
      "paid" -> "bg-[#C8001F]"
      "processing" -> "bg-pink-500"
      "shipped" -> "bg-indigo-500"
      "delivered" -> "bg-green-500"
      "cancelled" -> "bg-gray-400"
      "failed" -> "bg-red-400"
      _ -> "bg-gray-400"
    end
  end

  defp format_date(dt), do: Calendar.strftime(dt, "%d %b %Y, %H:%M")

  defp greeting do
    # rough EAT offset
    hour = DateTime.utc_now().hour + 3

    cond do
      hour < 12 -> "Good morning"
      hour < 17 -> "Good afternoon"
      true -> "Good evening"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-7">
      
    <!-- ── Hero greeting banner ── -->
      <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#C8001F] via-[#a8001a] to-[#6b0010] p-7 text-white shadow-lg">
        <!-- Decorative circles -->
        <div class="pointer-events-none absolute -right-12 -top-12 h-48 w-48 rounded-full bg-white/5">
        </div>
        <div class="pointer-events-none absolute -bottom-10 -right-4 h-32 w-32 rounded-full bg-white/5">
        </div>
        <div class="pointer-events-none absolute bottom-4 right-40 h-16 w-16 rounded-full bg-white/8">
        </div>

        <div class="relative flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p class="text-sm font-medium text-red-200">{greeting()}, welcome back ✨</p>
            <h1 class="mt-1 font-serif text-3xl font-bold tracking-tight">
              Sheglow's Closet
            </h1>
            <p class="mt-2 text-sm text-red-200 max-w-xs">
              Here's what's happening in your store today. Fashion .
            </p>
          </div>
          
    <!-- Revenue highlight -->
          <div class="flex-shrink-0 rounded-2xl bg-white/10 px-6 py-4 backdrop-blur-sm border border-white/20">
            <p class="text-xs font-semibold uppercase tracking-widest text-red-200">Total Revenue</p>
            <p class="mt-1 font-serif text-3xl font-bold tabular-nums">
              KES {@total_revenue |> fmt()}
            </p>
            <p class="mt-1 text-xs text-red-200">
              {@total_orders} confirmed {if @total_orders == 1, do: "order", else: "orders"}
            </p>
          </div>
        </div>
      </div>
      
    <!-- ── KPI cards ── -->
      <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <.kpi_card
          label="Orders"
          value={to_string(@total_orders)}
          sub="confirmed"
          icon="🛍️"
          accent="bg-rose-50 border-rose-100"
          value_class="text-rose-600"
        />
        <.kpi_card
          label="Customers"
          value={to_string(@total_customers)}
          sub="unique buyers"
          icon="👥"
          accent="bg-violet-50 border-violet-100"
          value_class="text-violet-600"
        />
        <.kpi_card
          label="Avg. Order"
          value={"KES #{fmt(@avg_order_value)}"}
          sub="per transaction"
          icon="💎"
          accent="bg-amber-50 border-amber-100"
          value_class="text-amber-600"
        />
        <.kpi_card
          label="Products"
          value={to_string(@total_products)}
          sub={"#{@total_collections} collections"}
          icon="👗"
          accent="bg-pink-50 border-pink-100"
          value_class="text-pink-600"
        />
      </div>
      
    <!-- ── Charts row ── -->
      <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        
    <!-- Revenue chart — 2/3 -->
        <div class="lg:col-span-2 overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-50 px-6 py-5">
            <div>
              <h2 class="font-serif text-base font-semibold text-gray-900">Revenue Trend</h2>
              <p class="text-xs text-gray-400">Last 30 days · confirmed orders only</p>
            </div>
            <span class="rounded-full bg-[#C8001F]/10 px-3 py-1 text-xs font-semibold text-[#C8001F]">
              KES {fmt(@total_revenue)}
            </span>
          </div>
          <div class="px-6 pb-6 pt-2">
            <div class="h-52">
              <canvas
                id="revenue-chart"
                phx-hook="ChartHook"
                data-type="line"
                data-chart={@revenue_chart}
              />
            </div>
          </div>
        </div>
        
    <!-- Status doughnut — 1/3 -->
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
          <div class="border-b border-gray-50 px-6 py-5">
            <h2 class="font-serif text-base font-semibold text-gray-900">Orders by Status</h2>
            <p class="text-xs text-gray-400">Distribution breakdown</p>
          </div>
          <div class="px-6 pb-4 pt-2">
            <div class="h-52">
              <canvas
                id="status-chart"
                phx-hook="ChartHook"
                data-type="doughnut"
                data-chart={@status_chart}
              />
            </div>
          </div>
        </div>
      </div>
      
    <!-- ── Bottom row ── -->
      <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        
    <!-- Top products — 2/3 -->
        <div class="lg:col-span-2 overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-50 px-6 py-5">
            <div>
              <h2 class="font-serif text-base font-semibold text-gray-900">Best-Selling Products</h2>
              <p class="text-xs text-gray-400">By total revenue across all orders</p>
            </div>
            <.link
              navigate="/admin/products"
              class="text-xs font-semibold text-[#C8001F] hover:underline"
            >
              Browse all →
            </.link>
          </div>
          <div class="px-6 pb-6 pt-2">
            <div class="h-56">
              <canvas
                id="top-products-chart"
                phx-hook="ChartHook"
                data-type="bar"
                data-chart={@top_products_chart}
              />
            </div>
          </div>
        </div>
        
    <!-- Recent orders — 1/3 -->
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-50 px-5 py-5">
            <h2 class="font-serif text-base font-semibold text-gray-900">Recent Orders</h2>
            <.link
              navigate="/admin/orders"
              class="text-xs font-semibold text-[#C8001F] hover:underline"
            >
              View all →
            </.link>
          </div>

          <div class="divide-y divide-gray-50">
            <%= if @recent_orders == [] do %>
              <div class="flex flex-col items-center py-12 text-center">
                <span class="text-4xl">🛍️</span>
                <p class="mt-3 text-sm text-gray-400">No orders yet</p>
              </div>
            <% else %>
              <%= for order <- @recent_orders do %>
                <.link
                  navigate={"/admin/orders/#{order.id}"}
                  class="flex items-center gap-3 px-5 py-3.5 transition hover:bg-gray-50/80"
                >
                  <!-- Avatar initials -->
                  <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-[#C8001F]/10 text-xs font-bold text-[#C8001F]">
                    {order.name
                    |> String.split()
                    |> Enum.take(2)
                    |> Enum.map(&String.first/1)
                    |> Enum.join()}
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="truncate text-xs font-semibold text-gray-900">{order.name}</p>
                    <p class="truncate font-mono text-[10px] text-gray-400">{order.reference}</p>
                  </div>
                  <div class="text-right flex-shrink-0">
                    <p class="text-xs font-bold text-gray-900">KES {fmt(order.total_amount)}</p>
                    <span class={[
                      "inline-flex items-center gap-1 rounded-full px-1.5 py-0.5 text-[9px] font-semibold capitalize",
                      status_pill(order.status)
                    ]}>
                      <span class={["h-1 w-1 rounded-full", status_dot(order.status)]} />
                      {order.status}
                    </span>
                  </div>
                </.link>
              <% end %>
            <% end %>
          </div>

          <%= if @recent_orders != [] do %>
            <div class="border-t border-gray-50 px-5 py-3 text-center">
              <p class="text-[10px] text-gray-400">
                Last order: {format_date(List.first(@recent_orders).inserted_at)}
              </p>
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- ── Status pills + Quick actions ── -->
      <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
        
    <!-- Status mini-tiles -->
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white p-5 shadow-sm">
          <h2 class="mb-4 font-serif text-base font-semibold text-gray-900">Order Pipeline</h2>
          <div class="grid grid-cols-3 gap-3">
            <%= for {status, label, icon} <- [
              {"paid",       "Paid",       "💳"},
              {"processing", "Processing", "⚙️"},
              {"shipped",    "Shipped",    "🚚"},
              {"delivered",  "Delivered",  "✅"},
              {"cancelled",  "Cancelled",  "✕"},
              {"failed",     "Failed",     "⚠️"}
            ] do %>
              <.link
                navigate="/admin/orders"
                class="group flex flex-col items-center rounded-2xl border border-gray-100 bg-gray-50/60 p-3 text-center transition hover:border-[#C8001F]/30 hover:bg-[#C8001F]/5"
              >
                <span class="text-xl">{icon}</span>
                <span class="mt-1 text-lg font-bold tabular-nums text-gray-900">
                  {Map.get(@status_counts, status, 0)}
                </span>
                <span class="text-[10px] font-medium text-gray-400 uppercase tracking-wide">
                  {label}
                </span>
              </.link>
            <% end %>
          </div>
        </div>
        
    <!-- Quick actions -->
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white p-5 shadow-sm">
          <h2 class="mb-4 font-serif text-base font-semibold text-gray-900">Quick Actions</h2>
          <div class="grid grid-cols-2 gap-3">
            <.link
              navigate="/admin/orders"
              class="group flex items-center gap-3 rounded-2xl border border-gray-100 bg-gray-50/60 p-4 transition hover:border-[#C8001F]/30 hover:bg-[#C8001F]/5"
            >
              <span class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-[#C8001F]/10 text-lg group-hover:bg-[#C8001F]/20 transition">
                🛍️
              </span>
              <div>
                <p class="text-sm font-semibold text-gray-900">Orders</p>
                <p class="text-xs text-gray-400">{Map.get(@status_counts, "all", 0)} total</p>
              </div>
            </.link>

            <.link
              navigate="/admin/customers"
              class="group flex items-center gap-3 rounded-2xl border border-gray-100 bg-gray-50/60 p-4 transition hover:border-[#C8001F]/30 hover:bg-[#C8001F]/5"
            >
              <span class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-violet-100 text-lg group-hover:bg-violet-200 transition">
                👥
              </span>
              <div>
                <p class="text-sm font-semibold text-gray-900">Customers</p>
                <p class="text-xs text-gray-400">{@total_customers} buyers</p>
              </div>
            </.link>

            <.link
              navigate="/admin/products"
              class="group flex items-center gap-3 rounded-2xl border border-gray-100 bg-gray-50/60 p-4 transition hover:border-[#C8001F]/30 hover:bg-[#C8001F]/5"
            >
              <span class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-pink-100 text-lg group-hover:bg-pink-200 transition">
                👗
              </span>
              <div>
                <p class="text-sm font-semibold text-gray-900">Products</p>
                <p class="text-xs text-gray-400">{@total_products} items</p>
              </div>
            </.link>

            <.link
              navigate="/admin/promotions"
              class="group flex items-center gap-3 rounded-2xl border border-gray-100 bg-gray-50/60 p-4 transition hover:border-[#C8001F]/30 hover:bg-[#C8001F]/5"
            >
              <span class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-amber-100 text-lg group-hover:bg-amber-200 transition">
                🏷️
              </span>
              <div>
                <p class="text-sm font-semibold text-gray-900">Promo Codes</p>
                <p class="text-xs text-gray-400">Influencer campaigns</p>
              </div>
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── Sub-components ────────────────────────────────────────────────────────

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :sub, :string, default: ""
  attr :icon, :string, default: "✦"
  attr :accent, :string, default: "bg-gray-50 border-gray-100"
  attr :value_class, :string, default: "text-gray-900"

  defp kpi_card(assigns) do
    ~H"""
    <div class={["overflow-hidden rounded-3xl border p-5 shadow-sm", @accent]}>
      <div class="flex items-start justify-between">
        <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">{@label}</p>
        <span class="text-xl leading-none">{@icon}</span>
      </div>
      <p class={["mt-3 font-serif text-2xl font-bold tabular-nums", @value_class]}>{@value}</p>
      <p class="mt-1 text-xs text-gray-400">{@sub}</p>
    </div>
    """
  end
end
