defmodule SheglowWeb.PromotionLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Promotions
  alias Sheglow.Promotions.PromoCode

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Promo Codes")
     |> assign(:current_path, "/admin/promotions")
     |> assign(:promo_codes, Promotions.list_promo_codes())
     |> assign(:selected_code, nil)
     |> assign(:selected_orders, [])
     |> assign(:selected_revenue, 0)
     |> assign(:show_form, false)
     |> assign(:editing, nil)
     |> assign(:form_error, nil)
     |> assign(:form, empty_form())}
  end

  # ── Events ────────────────────────────────────────────────────────────────

  @impl true
  def handle_event("new_promo", _, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing, nil)
     |> assign(:form, empty_form())
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("edit_promo", %{"id" => id}, socket) do
    promo = Promotions.get_promo_code!(id)

    form = %{
      "code"             => promo.code,
      "description"      => promo.description || "",
      "influencer_name"  => promo.influencer_name || "",
      "discount_percent" => to_string(promo.discount_percent),
      "is_active"        => to_string(promo.is_active),
      "max_uses"         => if(promo.max_uses, do: to_string(promo.max_uses), else: ""),
      "expires_at"       => if(promo.expires_at, do: Calendar.strftime(promo.expires_at, "%Y-%m-%dT%H:%M"), else: "")
    }

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing, promo)
     |> assign(:form, form)
     |> assign(:form_error, nil)}
  end

  @impl true
  def handle_event("cancel_form", _, socket) do
    {:noreply, socket |> assign(:show_form, false) |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("update_form", params, socket) do
    keys = ~w(code description influencer_name discount_percent is_active max_uses expires_at)
    form = Map.merge(socket.assigns.form, Map.take(params, keys))
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("save_promo", _params, socket) do
    %{form: form, editing: editing} = socket.assigns

    attrs = build_attrs(form)

    result =
      if editing do
        Promotions.update_promo_code(editing, attrs)
      else
        Promotions.create_promo_code(attrs)
      end

    case result do
      {:ok, _promo} ->
        {:noreply,
         socket
         |> assign(:promo_codes, Promotions.list_promo_codes())
         |> assign(:show_form, false)
         |> assign(:editing, nil)
         |> put_flash(:info, if(editing, do: "Promo code updated!", else: "Promo code created!"))}

      {:error, changeset} ->
        error =
          changeset.errors
          |> Enum.map(fn {k, {msg, _}} -> "#{k} #{msg}" end)
          |> Enum.join(", ")

        {:noreply, assign(socket, :form_error, error)}
    end
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    promo = Promotions.get_promo_code!(id)

    case Promotions.update_promo_code(promo, %{is_active: !promo.is_active}) do
      {:ok, _} ->
        {:noreply, assign(socket, :promo_codes, Promotions.list_promo_codes())}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update status.")}
    end
  end

  @impl true
  def handle_event("delete_promo", %{"id" => id}, socket) do
    promo = Promotions.get_promo_code!(id)
    Promotions.delete_promo_code(promo)

    {:noreply,
     socket
     |> assign(:promo_codes, Promotions.list_promo_codes())
     |> assign(:selected_code, nil)
     |> put_flash(:info, "Promo code deleted.")}
  end

  @impl true
  def handle_event("view_orders", %{"code" => code}, socket) do
    orders  = Promotions.list_orders_for_code(code)
    revenue = Promotions.revenue_for_code(code)

    {:noreply,
     socket
     |> assign(:selected_code, code)
     |> assign(:selected_orders, orders)
     |> assign(:selected_revenue, revenue)}
  end

  @impl true
  def handle_event("close_orders", _, socket) do
    {:noreply, socket |> assign(:selected_code, nil) |> assign(:selected_orders, [])}
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp empty_form do
    %{
      "code"             => "",
      "description"      => "",
      "influencer_name"  => "",
      "discount_percent" => "10",
      "is_active"        => "true",
      "max_uses"         => "",
      "expires_at"       => ""
    }
  end

  defp build_attrs(form) do
    %{
      code:             form["code"],
      description:      blank_to_nil(form["description"]),
      influencer_name:  blank_to_nil(form["influencer_name"]),
      discount_percent: parse_int(form["discount_percent"]),
      is_active:        form["is_active"] == "true",
      max_uses:         parse_int_or_nil(form["max_uses"]),
      expires_at:       parse_datetime(form["expires_at"])
    }
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp parse_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> nil
    end
  end
  defp parse_int(n) when is_integer(n), do: n
  defp parse_int(_), do: nil

  defp parse_int_or_nil(""), do: nil
  defp parse_int_or_nil(s), do: parse_int(s)

  defp parse_datetime(""), do: nil
  defp parse_datetime(nil), do: nil
  defp parse_datetime(s) do
    case DateTime.from_iso8601("#{s}:00Z") do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp fmt(n), do: SheglowWeb.Format.price(n)

  defp format_date(nil), do: "—"
  defp format_date(dt), do: Calendar.strftime(dt, "%d %b %Y")

  defp status_badge(order) do
    case order.status do
      "paid"       -> "bg-[#C8001F]/10 text-[#C8001F]"
      "processing" -> "bg-pink-50 text-pink-700"
      "shipped"    -> "bg-indigo-50 text-indigo-600"
      "delivered"  -> "bg-green-50 text-green-700"
      "cancelled"  -> "bg-gray-100 text-gray-500"
      _            -> "bg-gray-100 text-gray-500"
    end
  end

  defp item_count(items) when is_list(items) do
    Enum.reduce(items, 0, fn i, acc -> acc + (i["quantity"] || 1) end)
  end
  defp item_count(_), do: 0

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">

      <!-- ── Page banner ── -->
      <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#C8001F] to-[#8b0014] px-7 py-6 text-white shadow-md">
        <div class="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-white/5"></div>
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p class="text-xs font-medium uppercase tracking-widest text-red-200">Store</p>
            <h1 class="mt-0.5 font-serif text-2xl font-bold">Promo Codes</h1>
            <p class="mt-1 text-xs text-red-200">{length(@promo_codes)} codes · track influencer-driven sales</p>
          </div>
          <button
            phx-click="new_promo"
            class="flex-shrink-0 flex items-center gap-2 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-[#C8001F] shadow-sm transition hover:bg-red-50"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            New Promo Code
          </button>
        </div>
      </div>

      <!-- ── Create / Edit Form ── -->
      <%= if @show_form do %>
        <div class="overflow-hidden rounded-3xl border border-[#C8001F]/20 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
            <h2 class="font-serif text-base font-semibold text-gray-900">
              {if @editing, do: "Edit Promo Code", else: "Create New Promo Code"}
            </h2>
            <button phx-click="cancel_form" class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-700">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>

          <%= if @form_error do %>
            <div class="mx-6 mt-4 flex items-center gap-2 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
              <svg class="h-4 w-4 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {@form_error}
            </div>
          <% end %>

          <form phx-submit="save_promo" phx-change="update_form" class="grid gap-5 px-6 py-5 sm:grid-cols-2 lg:grid-cols-3">
            <!-- Code -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Promo Code *</label>
              <input
                type="text"
                name="code"
                value={@form["code"]}
                placeholder="GRACE20"
                class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 font-mono text-sm uppercase tracking-widest placeholder-gray-300 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
              />
              <p class="mt-1 text-[10px] text-gray-400">Letters, numbers, hyphens only. Auto-uppercased.</p>
            </div>

            <!-- Influencer name -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Influencer / Creator</label>
              <input
                type="text"
                name="influencer_name"
                value={@form["influencer_name"]}
                placeholder="Grace Njeri"
                class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 text-sm placeholder-gray-300 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
              />
            </div>

            <!-- Discount % -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Discount % *</label>
              <div class="relative">
                <input
                  type="number"
                  name="discount_percent"
                  value={@form["discount_percent"]}
                  min="1"
                  max="100"
                  placeholder="10"
                  class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 pr-8 text-sm placeholder-gray-300 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
                />
                <span class="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm font-bold text-gray-400">%</span>
              </div>
            </div>

            <!-- Description -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Description</label>
              <input
                type="text"
                name="description"
                value={@form["description"]}
                placeholder="Summer sale for Grace's followers"
                class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 text-sm placeholder-gray-300 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
              />
            </div>

            <!-- Max uses -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Max Uses</label>
              <input
                type="number"
                name="max_uses"
                value={@form["max_uses"]}
                min="1"
                placeholder="Unlimited"
                class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 text-sm placeholder-gray-300 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
              />
              <p class="mt-1 text-[10px] text-gray-400">Leave empty for unlimited uses.</p>
            </div>

            <!-- Expires at -->
            <div>
              <label class="mb-1.5 block text-xs font-semibold uppercase tracking-widest text-gray-400">Expires At</label>
              <input
                type="datetime-local"
                name="expires_at"
                value={@form["expires_at"]}
                class="w-full rounded-xl border border-gray-200 px-3.5 py-2.5 text-sm text-gray-700 transition focus:border-[#C8001F]/50 focus:outline-none focus:ring-2 focus:ring-[#C8001F]/10"
              />
              <p class="mt-1 text-[10px] text-gray-400">Leave empty for no expiry.</p>
            </div>

            <!-- Active toggle -->
            <div class="flex items-center gap-3 pt-1">
              <input type="hidden" name="is_active" value="false" />
              <input
                type="checkbox"
                name="is_active"
                value="true"
                checked={@form["is_active"] == "true"}
                id="is_active_check"
                class="h-4 w-4 rounded accent-[#C8001F]"
              />
              <label for="is_active_check" class="text-sm font-medium text-gray-700">Active (usable at checkout)</label>
            </div>

            <!-- Submit row spans full width -->
            <div class="flex items-center gap-3 sm:col-span-2 lg:col-span-3">
              <button
                type="submit"
                class="rounded-xl bg-[#C8001F] px-6 py-2.5 text-sm font-semibold text-white transition hover:bg-[#a8001a]"
              >
                {if @editing, do: "Save Changes", else: "Create Promo Code"}
              </button>
              <button type="button" phx-click="cancel_form" class="rounded-xl border border-gray-200 px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50">
                Cancel
              </button>
            </div>
          </form>
        </div>
      <% end %>

      <!-- ── Promo Codes Table ── -->
      <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
        <div class="border-b border-gray-100 px-6 py-5">
          <h2 class="font-serif text-base font-semibold text-gray-900">All Promo Codes</h2>
        </div>

        <%= if @promo_codes == [] do %>
          <div class="flex flex-col items-center py-16 text-center">
            <span class="text-5xl">🏷️</span>
            <p class="mt-4 text-sm font-medium text-gray-500">No promo codes yet</p>
            <p class="mt-1 text-xs text-gray-400">Create your first code for an influencer campaign.</p>
          </div>
        <% else %>
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="border-b border-gray-100 bg-gray-50/80">
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Code</th>
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Influencer</th>
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Discount</th>
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Uses</th>
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Status</th>
                  <th class="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-400">Expires</th>
                  <th class="px-5 py-3.5 text-right text-[11px] font-semibold uppercase tracking-wider text-gray-400">Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for promo <- @promo_codes do %>
                  <tr class="group border-b border-gray-100 transition-colors last:border-0 hover:bg-[#C8001F]/3">
                    <!-- Code -->
                    <td class="px-5 py-3.5">
                      <div class="flex items-center gap-2.5">
                        <span class="rounded-lg bg-[#C8001F]/10 px-2.5 py-1 font-mono text-sm font-bold tracking-widest text-[#C8001F]">
                          {promo.code}
                        </span>
                      </div>
                      <%= if promo.description not in [nil, ""] do %>
                        <p class="mt-0.5 text-[11px] text-gray-400">{promo.description}</p>
                      <% end %>
                    </td>

                    <!-- Influencer -->
                    <td class="px-5 py-3.5">
                      <%= if promo.influencer_name not in [nil, ""] do %>
                        <span class="text-sm font-medium text-gray-800">{promo.influencer_name}</span>
                      <% else %>
                        <span class="text-xs text-gray-300">—</span>
                      <% end %>
                    </td>

                    <!-- Discount -->
                    <td class="px-5 py-3.5">
                      <span class="inline-flex items-center rounded-full bg-green-50 px-2.5 py-1 text-sm font-bold text-green-700">
                        -{promo.discount_percent}%
                      </span>
                    </td>

                    <!-- Uses -->
                    <td class="px-5 py-3.5">
                      <button
                        phx-click="view_orders"
                        phx-value-code={promo.code}
                        class="group/btn flex items-center gap-1.5 rounded-lg bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-700 transition hover:bg-[#C8001F]/10 hover:text-[#C8001F]"
                        title="View orders for this code"
                      >
                        <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                        </svg>
                        {promo.usage_count}
                        {if promo.max_uses, do: "/ #{promo.max_uses}", else: "uses"}
                      </button>
                    </td>

                    <!-- Status toggle -->
                    <td class="px-5 py-3.5">
                      <button
                        phx-click="toggle_active"
                        phx-value-id={promo.id}
                        class={[
                          "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold transition",
                          if(promo.is_active,
                            do: "bg-green-50 text-green-700 hover:bg-red-50 hover:text-red-600",
                            else: "bg-gray-100 text-gray-500 hover:bg-green-50 hover:text-green-600"
                          )
                        ]}
                        title={if promo.is_active, do: "Click to deactivate", else: "Click to activate"}
                      >
                        <span class={["h-1.5 w-1.5 rounded-full", if(promo.is_active, do: "bg-green-500", else: "bg-gray-400")]} />
                        {if promo.is_active, do: "Active", else: "Inactive"}
                      </button>
                    </td>

                    <!-- Expires -->
                    <td class="px-5 py-3.5">
                      <span class="text-xs text-gray-400">{format_date(promo.expires_at)}</span>
                    </td>

                    <!-- Actions -->
                    <td class="px-5 py-3.5">
                      <div class="flex items-center justify-end gap-1.5 opacity-0 transition-opacity group-hover:opacity-100">
                        <button
                          phx-click="edit_promo"
                          phx-value-id={promo.id}
                          class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-[#C8001F]/30 hover:text-[#C8001F]"
                          title="Edit"
                        >
                          <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
                          </svg>
                        </button>
                        <button
                          phx-click="delete_promo"
                          phx-value-id={promo.id}
                          data-confirm={"Delete code #{promo.code}? This cannot be undone."}
                          class="flex h-8 w-8 items-center justify-center rounded-lg border border-gray-200 text-gray-400 transition hover:border-red-200 hover:bg-red-50 hover:text-red-500"
                          title="Delete"
                        >
                          <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6M9 6V4a1 1 0 011-1h4a1 1 0 011 1v2M4 7h16"/>
                          </svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>

      <!-- ── Orders panel (slide-in) ── -->
      <%= if @selected_code do %>
        <div class="overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
          <div class="flex items-center justify-between border-b border-gray-100 px-6 py-5">
            <div>
              <h2 class="font-serif text-base font-semibold text-gray-900">
                Orders using
                <span class="ml-1.5 font-mono text-[#C8001F]">{@selected_code}</span>
              </h2>
              <p class="mt-0.5 text-xs text-gray-400">
                {length(@selected_orders)} orders ·
                KES {fmt(@selected_revenue)} total revenue (paid+)
              </p>
            </div>
            <button phx-click="close_orders" class="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-700">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>

          <%= if @selected_orders == [] do %>
            <div class="py-12 text-center text-sm text-gray-400">No orders yet for this code.</div>
          <% else %>
            <div class="divide-y divide-gray-50">
              <%= for order <- @selected_orders do %>
                <.link navigate={"/admin/orders/#{order.id}"}
                  class="flex items-center gap-4 px-6 py-4 transition hover:bg-[#C8001F]/3">
                  <div class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-full bg-[#C8001F]/10 text-xs font-bold text-[#C8001F]">
                    {order.name |> String.split() |> Enum.take(2) |> Enum.map(&String.first/1) |> Enum.join()}
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="truncate text-sm font-semibold text-gray-900">{order.name}</p>
                    <p class="truncate font-mono text-[10px] text-gray-400">{order.reference}</p>
                  </div>
                  <div class="text-right">
                    <p class="text-sm font-bold text-gray-900">KES {fmt(order.total_amount)}</p>
                    <%= if order.discount_amount > 0 do %>
                      <p class="text-[10px] font-medium text-green-600">-KES {fmt(order.discount_amount)}</p>
                    <% end %>
                  </div>
                  <span class={[
                    "flex-shrink-0 rounded-full px-2 py-0.5 text-[10px] font-semibold capitalize",
                    status_badge(order)
                  ]}>
                    {order.status}
                  </span>
                  <span class="text-xs text-gray-400 flex-shrink-0">{format_date(order.inserted_at)}</span>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>

    </div>
    """
  end
end
