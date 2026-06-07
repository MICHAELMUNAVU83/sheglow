defmodule SheglowWeb.CheckoutLive.Index do
  use SheglowWeb, :live_view
  import SheglowWeb.HomeComponents

  alias Sheglow.Orders
  alias Sheglow.Paystack
  alias Sheglow.Promotions

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Checkout | SheGlow UG")
     |> assign(:cart_items, [])
     |> assign(:cart_loaded, false)
     |> assign(:submitting, false)
     |> assign(:form_error, nil)
     |> assign(:promo_input, "")
     |> assign(:applied_promo, nil)
     |> assign(:promo_error, nil)
     |> assign(:form, %{"name" => "", "email" => "", "phone" => "", "address" => ""})}
  end

  @impl true
  def handle_event("cart_loaded", %{"items" => items}, socket) do
    {:noreply,
     socket
     |> assign(:cart_items, items)
     |> assign(:cart_loaded, true)}
  end

  @impl true
  def handle_event("update_form", params, socket) do
    form = Map.merge(socket.assigns.form, Map.take(params, ["name", "email", "phone", "address"]))
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("update_promo_input", %{"value" => v}, socket) do
    {:noreply, assign(socket, :promo_input, v)}
  end

  @impl true
  def handle_event("apply_promo", _params, socket) do
    code = String.trim(socket.assigns.promo_input)

    case Promotions.validate_code(code) do
      {:ok, promo} ->
        {:noreply,
         socket
         |> assign(:applied_promo, promo)
         |> assign(:promo_error, nil)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:applied_promo, nil)
         |> assign(:promo_error, reason)}
    end
  end

  @impl true
  def handle_event("remove_promo", _params, socket) do
    {:noreply,
     socket
     |> assign(:applied_promo, nil)
     |> assign(:promo_input, "")
     |> assign(:promo_error, nil)}
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
  def handle_event("place_order", _params, socket) do
    %{cart_items: items, form: form, applied_promo: promo} = socket.assigns

    cond do
      items == [] ->
        {:noreply, assign(socket, :form_error, "Your cart is empty.")}

      form["name"] == "" ->
        {:noreply, assign(socket, :form_error, "Please enter your full name.")}

      form["email"] == "" ->
        {:noreply, assign(socket, :form_error, "Please enter your email address.")}

      not String.contains?(form["email"], "@") ->
        {:noreply, assign(socket, :form_error, "Please enter a valid email address.")}

      true ->
        socket = assign(socket, submitting: true, form_error: nil)

        subtotal = calc_subtotal(items)
        discount_amount = if promo, do: Promotions.calc_discount(promo, subtotal), else: 0
        total = subtotal - discount_amount
        reference = Orders.generate_reference()

        order_attrs = %{
          reference: reference,
          email: form["email"],
          name: form["name"],
          phone: form["phone"],
          address: form["address"],
          total_amount: total,
          discount_amount: discount_amount,
          promo_code: if(promo, do: promo.code, else: nil),
          items: items
        }

        case Orders.create_order(order_attrs) do
          {:ok, _order} ->
            case Paystack.initialize(form["email"], total, reference) do
              %{"authorization_url" => url} ->
                {:noreply, redirect(socket, external: url)}

              %{"error" => reason} ->
                {:noreply,
                 socket
                 |> assign(:submitting, false)
                 |> assign(:form_error, "Payment setup failed: #{reason}")}

              _ ->
                {:noreply,
                 socket
                 |> assign(:submitting, false)
                 |> assign(:form_error, "Payment setup failed. Please try again.")}
            end

          {:error, changeset} ->
            error = changeset.errors |> Enum.map(fn {k, {m, _}} -> "#{k}: #{m}" end) |> hd()

            {:noreply,
             socket
             |> assign(:submitting, false)
             |> assign(:form_error, error)}
        end
    end
  end

  defp calc_subtotal(items) do
    Enum.reduce(items, 0, fn item, acc ->
      acc + (item["price"] || 0) * (item["quantity"] || 1)
    end)
  end

  defp calc_total(items, promo) do
    sub = calc_subtotal(items)
    discount = if promo, do: Promotions.calc_discount(promo, sub), else: 0
    sub - discount
  end

  defp fmt(n), do: SheglowWeb.Format.price(n)

  @impl true
  def render(assigns) do
    ~H"""
    <div id="checkout-page" class="min-h-screen bg-[#f9f9f7]" phx-hook="CartSync">
      <.navbar cart_items={@cart_items} collections={[]} />

      <div class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="mb-8 flex items-center gap-3">
          <a
            href="/cart"
            class="rounded-full p-1.5 text-gray-400 transition hover:bg-gray-200 hover:text-black"
          >
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </a>
          <h1 class="text-2xl font-bold text-gray-900 sm:text-3xl">Checkout</h1>
        </div>

        <div class="grid gap-8 lg:grid-cols-5">
          
    <!-- ── Left: Contact & Delivery form ── -->
          <div class="lg:col-span-3">
            <div class="rounded-2xl border border-gray-200 bg-white p-7 shadow-sm">
              <h2 class="mb-1 text-lg font-semibold text-gray-900">Contact & Delivery</h2>
              <p class="mb-6 text-sm text-gray-400">We'll send your confirmation here.</p>

              <%= if @form_error do %>
                <div class="mb-5 flex items-center gap-2 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
                  <svg class="h-4 w-4 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  {@form_error}
                </div>
              <% end %>

              <form phx-submit="place_order" phx-change="update_form" class="space-y-5">
                <div class="grid gap-5 sm:grid-cols-2">
                  <div>
                    <label class="mb-1.5 block text-sm font-medium text-gray-700">Full Name *</label>
                    <input
                      type="text"
                      name="name"
                      value={@form["name"]}
                      placeholder="Jane Doe"
                      required
                      class="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm placeholder-gray-400 transition focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                    />
                  </div>
                  <div>
                    <label class="mb-1.5 block text-sm font-medium text-gray-700">
                      Email Address *
                    </label>
                    <input
                      type="email"
                      name="email"
                      value={@form["email"]}
                      placeholder="jane@example.com"
                      required
                      class="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm placeholder-gray-400 transition focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                    />
                  </div>
                </div>

                <div>
                  <label class="mb-1.5 block text-sm font-medium text-gray-700">Phone Number</label>
                  <input
                    type="tel"
                    name="phone"
                    value={@form["phone"]}
                    placeholder="+254 700 000 000"
                    class="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm placeholder-gray-400 transition focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                  />
                </div>

                <div>
                  <label class="mb-1.5 block text-sm font-medium text-gray-700">
                    Delivery Address
                  </label>
                  <textarea
                    name="address"
                    rows="3"
                    placeholder="Street, City, County"
                    class="w-full resize-none rounded-xl border border-gray-300 px-4 py-3 text-sm placeholder-gray-400 transition focus:border-[#C8001F]/60 focus:outline-none focus:ring-1 focus:ring-[#C8001F]/30"
                  >{@form["address"]}</textarea>
                </div>
                
    <!-- ── Promo Code ── -->
                <div class="border-t border-gray-100 pt-5">
                  <label class="mb-2 block text-sm font-medium text-gray-700">
                    Promo / Discount Code
                  </label>

                  <%= if @applied_promo do %>
                    <!-- Applied state -->
                    <div class="flex items-center gap-3 rounded-xl border border-green-200 bg-green-50 px-4 py-3">
                      <svg
                        class="h-5 w-5 flex-shrink-0 text-green-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      </svg>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-semibold text-green-800">
                          <span class="font-mono">{@applied_promo.code}</span>
                          · -{@applied_promo.discount_percent}% off applied!
                        </p>
                        <%= if @applied_promo.influencer_name not in [nil, ""] do %>
                          <p class="text-xs text-green-600">By {@applied_promo.influencer_name}</p>
                        <% end %>
                      </div>
                      <button
                        type="button"
                        phx-click="remove_promo"
                        class="rounded-lg px-2.5 py-1 text-xs font-medium text-green-700 transition hover:bg-green-100"
                      >
                        Remove
                      </button>
                    </div>
                  <% else %>
                    <!-- Input state -->
                    <div class="flex gap-2">
                      <input
                        type="text"
                        placeholder="Enter promo code"
                        value={@promo_input}
                        phx-input="update_promo_input"
                        class={[
                          "flex-1 rounded-xl border px-4 py-3 font-mono text-sm uppercase tracking-widest placeholder-gray-300 transition focus:outline-none focus:ring-1",
                          if(@promo_error,
                            do: "border-red-300 focus:border-red-400 focus:ring-red-200",
                            else: "border-gray-300 focus:border-[#C8001F]/60 focus:ring-[#C8001F]/20"
                          )
                        ]}
                      />
                      <button
                        type="button"
                        phx-click="apply_promo"
                        class="flex-shrink-0 rounded-xl border border-[#C8001F] px-5 py-3 text-sm font-semibold text-[#C8001F] transition hover:bg-[#C8001F] hover:text-white"
                      >
                        Apply
                      </button>
                    </div>
                    <%= if @promo_error do %>
                      <p class="mt-1.5 flex items-center gap-1 text-xs text-red-600">
                        <svg class="h-3.5 w-3.5" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            fill-rule="evenodd"
                            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                            clip-rule="evenodd"
                          />
                        </svg>
                        {@promo_error}
                      </p>
                    <% end %>
                  <% end %>
                </div>
                
    <!-- Totals summary -->
                <div class="space-y-1.5">
                  <div class="flex items-center justify-between text-sm text-gray-500">
                    <span>Subtotal</span>
                    <span class="font-medium text-gray-700">
                      UGX {fmt(calc_subtotal(@cart_items))}
                    </span>
                  </div>
                  <%= if @applied_promo do %>
                    <div class="flex items-center justify-between text-sm text-green-600">
                      <span>Discount ({@applied_promo.discount_percent}% off)</span>
                      <span class="font-semibold">
                        -UGX {fmt(
                          Promotions.calc_discount(@applied_promo, calc_subtotal(@cart_items))
                        )}
                      </span>
                    </div>
                  <% end %>
                  <div class="flex items-center justify-between text-sm text-gray-500">
                    <span>Shipping</span>
                    <span class="font-medium text-green-600">Free</span>
                  </div>
                  <div class="flex items-center justify-between border-t border-gray-100 pt-2 text-base font-bold text-gray-900">
                    <span>Total</span>
                    <span class="text-[#C8001F]">
                      UGX {fmt(calc_total(@cart_items, @applied_promo))}
                    </span>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={@submitting or @cart_items == []}
                  class="w-full rounded-full bg-[#C8001F] py-3.5 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)] disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <%= if @submitting do %>
                    <span class="flex items-center justify-center gap-2">
                      <svg class="h-4 w-4 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle
                          class="opacity-25"
                          cx="12"
                          cy="12"
                          r="10"
                          stroke="currentColor"
                          stroke-width="4"
                        >
                        </circle>
                        <path
                          class="opacity-75"
                          fill="currentColor"
                          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                        >
                        </path>
                      </svg>
                      Redirecting to payment…
                    </span>
                  <% else %>
                    Pay with Paystack →
                  <% end %>
                </button>

                <div class="flex items-center justify-center gap-1.5 text-xs text-gray-400">
                  <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                    />
                  </svg>
                  Secured & encrypted by Paystack
                </div>
              </form>
            </div>
          </div>
          
    <!-- ── Right: Editable cart ── -->
          <div class="lg:col-span-2">
            <div class="rounded-2xl border border-gray-200 bg-white shadow-sm">
              <div class="flex items-center justify-between border-b border-gray-100 px-6 py-4">
                <h2 class="font-semibold text-gray-900">Your Order</h2>
                <span class="rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-600">
                  {length(@cart_items)} {if length(@cart_items) == 1, do: "item", else: "items"}
                </span>
              </div>

              <div class="divide-y divide-gray-50 px-6">
                <%= if @cart_items == [] do %>
                  <div class="py-10 text-center">
                    <p class="text-sm text-gray-400">No items in your cart.</p>
                    <a
                      href="/"
                      class="mt-3 inline-block text-sm font-medium text-[#C8001F] underline underline-offset-2"
                    >
                      Keep shopping
                    </a>
                  </div>
                <% else %>
                  <%= for item <- @cart_items do %>
                    <div class="flex gap-4 py-4">
                      <div class="h-20 w-16 flex-shrink-0 overflow-hidden rounded-xl bg-gray-100">
                        <%= if item["image"] do %>
                          <img
                            src={item["image"]}
                            alt={item["name"]}
                            class="h-full w-full object-cover"
                          />
                        <% else %>
                          <div class="flex h-full items-center justify-center text-2xl">👗</div>
                        <% end %>
                      </div>

                      <div class="flex flex-1 flex-col justify-between min-w-0">
                        <div class="flex items-start justify-between gap-2">
                          <div class="min-w-0">
                            <p class="truncate text-sm font-semibold text-gray-900">{item["name"]}</p>
                            <p class="mt-0.5 text-xs text-gray-400">
                              {if item["color"], do: item["color"]}
                              {if item["color"] && item["size"], do: " · "}
                              {if item["size"], do: item["size"]}
                            </p>
                          </div>
                          <button
                            phx-click="remove_item"
                            phx-value-key={item["key"]}
                            class="flex-shrink-0 rounded-lg p-1 text-gray-300 transition hover:bg-red-50 hover:text-red-500"
                          >
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                              />
                            </svg>
                          </button>
                        </div>

                        <div class="flex items-center justify-between">
                          <div class="flex items-center gap-1 rounded-full border border-gray-200 px-2 py-1">
                            <button
                              phx-click="update_quantity"
                              phx-value-key={item["key"]}
                              phx-value-quantity={max(1, (item["quantity"] || 1) - 1)}
                              class="flex h-5 w-5 items-center justify-center rounded-full text-gray-500 transition hover:bg-gray-100 hover:text-black"
                            >
                              −
                            </button>
                            <span class="w-5 text-center text-sm font-medium text-gray-800">
                              {item["quantity"] || 1}
                            </span>
                            <button
                              phx-click="update_quantity"
                              phx-value-key={item["key"]}
                              phx-value-quantity={(item["quantity"] || 1) + 1}
                              class="flex h-5 w-5 items-center justify-center rounded-full text-gray-500 transition hover:bg-gray-100 hover:text-black"
                            >
                              +
                            </button>
                          </div>
                          <span class="text-sm font-semibold text-gray-900">
                            UGX {fmt((item["price"] || 0) * (item["quantity"] || 1))}
                          </span>
                        </div>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>

              <%= if @cart_items != [] do %>
                <div class="border-t border-gray-100 px-6 py-4 space-y-1.5">
                  <%= if @applied_promo do %>
                    <div class="flex justify-between text-sm text-green-600">
                      <span>
                        Discount ({@applied_promo.discount_percent}% · <span class="font-mono">{@applied_promo.code}</span>)
                      </span>
                      <span class="font-semibold">
                        -UGX {fmt(
                          Promotions.calc_discount(@applied_promo, calc_subtotal(@cart_items))
                        )}
                      </span>
                    </div>
                  <% end %>
                  <div class="flex justify-between text-sm text-gray-500">
                    <span>Shipping</span>
                    <span class="font-medium text-green-600">Free</span>
                  </div>
                  <div class="flex justify-between border-t border-gray-100 pt-2 text-base font-bold text-gray-900">
                    <span>Total</span>
                    <span class="text-[#C8001F]">
                      UGX {fmt(calc_total(@cart_items, @applied_promo))}
                    </span>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <.footer />
    </div>
    """
  end
end
