defmodule SheglowWeb.SuccessLive.Index do
  use SheglowWeb, :live_view
  import SheglowWeb.HomeComponents
  require Logger

  alias Sheglow.Orders
  alias Sheglow.Paystack
  alias Sheglow.OrderNotifier

  @impl true
  def mount(params, _session, socket) do
    reference = Map.get(params, "reference", "")

    if reference == "" do
      {:ok,
       socket
       |> assign(:page_title, "Order | Sheglow")
       |> assign(:status, :no_reference)
       |> assign(:order, nil)}
    else
      socket =
        assign(socket, page_title: "Order Confirmed | Sheglow", status: :verifying, order: nil)

      if connected?(socket) do
        send(self(), {:verify_payment, reference})
      end

      {:ok, socket}
    end
  end

  @impl true
  def handle_info({:verify_payment, reference}, socket) do
    case Orders.get_order_by_reference(reference) do
      nil ->
        {:noreply, assign(socket, status: :not_found)}

      order when order.status == "paid" ->
        # Already processed
        {:noreply,
         socket
         |> assign(:status, :success)
         |> assign(:order, order)
         |> push_event("clear-cart", %{})}

      order ->
        case Paystack.verify(reference) do
          {:ok, _data} ->
            {:ok, paid_order} = Orders.mark_paid(order)

            # Fire-and-forget emails
            Task.start(fn ->
              try do
                case OrderNotifier.send_confirmation(paid_order) do
                  {:ok, _} ->
                    Logger.info(
                      "[Email] Order confirmation sent to #{paid_order.email} for #{paid_order.reference}"
                    )

                  {:error, reason} ->
                    Logger.error(
                      "[Email] Failed to send confirmation to #{paid_order.email}: #{inspect(reason)}"
                    )
                end

                case OrderNotifier.send_admin_notification(paid_order) do
                  {:ok, _} ->
                    :ok

                  {:error, reason} ->
                    Logger.error("[Email] Failed to send admin notification: #{inspect(reason)}")
                end
              rescue
                e ->
                  Logger.error(
                    "[Email] Exception sending order emails for #{paid_order.reference}: #{Exception.message(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
                  )
              end
            end)

            {:noreply,
             socket
             |> assign(:status, :success)
             |> assign(:order, paid_order)
             |> push_event("clear-cart", %{})}

          {:error, reason} ->
            Orders.mark_failed(order)

            {:noreply,
             socket
             |> assign(:status, :failed)
             |> assign(:order, %{reference: reference, reason: reason})}
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="success-page" class="min-h-screen bg-white" phx-hook="CartHook">
      <.navbar cart_items={[]} />

      <div class="mx-auto max-w-2xl px-4 py-20 text-center sm:px-6">
        <%= case @status do %>
          <% :verifying -> %>
            <div class="flex flex-col items-center gap-6">
              <svg class="h-16 w-16 animate-spin text-gray-300" fill="none" viewBox="0 0 24 24">
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
              <p class="text-lg text-gray-600">Verifying your payment…</p>
            </div>
          <% :success -> %>
            <!-- Success -->
            <div class="flex flex-col items-center">
              <div class="flex h-20 w-20 items-center justify-center rounded-full bg-green-100">
                <svg
                  class="h-10 w-10 text-green-500"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </div>

              <h1 class="mt-6 text-3xl font-bold text-gray-900">Order Confirmed!</h1>
              <p class="mt-3 text-gray-600">
                Thank you, <strong>{@order.name}</strong>! Your payment was successful and your order is being prepared.
              </p>

              <div class="mt-8 w-full rounded-xl border border-gray-100 bg-gray-50 p-6 text-left">
                <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">
                  Order Reference
                </p>
                <p class="mt-1 text-xl font-bold text-gray-900">{@order.reference}</p>

                <div class="mt-6 space-y-3">
                  <%= for item <- @order.items do %>
                    <div class="flex items-center gap-3">
                      <div class="h-12 w-10 flex-shrink-0 overflow-hidden rounded-md bg-gray-200">
                        <%= if item["image"] do %>
                          <img
                            src={item["image"]}
                            alt={item["name"]}
                            class="h-full w-full object-cover"
                          />
                        <% else %>
                          <div class="flex h-full items-center justify-center text-lg">👗</div>
                        <% end %>
                      </div>
                      <div class="flex-1">
                        <p class="text-sm font-medium text-gray-900">{item["name"]}</p>
                        <p class="text-xs text-gray-500">
                          {item["size"]} · {item["color"]} · x{item["quantity"] || 1}
                        </p>
                      </div>
                      <span class="text-sm font-semibold">
                        UGX {SheglowWeb.Format.price((item["price"] || 0) * (item["quantity"] || 1))}
                      </span>
                    </div>
                  <% end %>
                </div>

                <div class="mt-5 border-t border-gray-200 pt-4 flex justify-between font-bold text-gray-900">
                  <span>Total Paid</span>
                  <span>UGX {SheglowWeb.Format.price(@order.total_amount)}</span>
                </div>
              </div>

              <p class="mt-6 text-sm text-gray-500">
                A confirmation email has been sent to <strong>{@order.email}</strong>
              </p>

              <div class="mt-8 flex flex-wrap justify-center gap-4">
                <a
                  href="/"
                  class="rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
                >
                  Continue Shopping
                </a>
              </div>
            </div>
          <% :failed -> %>
            <div class="flex flex-col items-center">
              <div class="flex h-20 w-20 items-center justify-center rounded-full bg-red-100">
                <svg
                  class="h-10 w-10 text-red-500"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </div>
              <h1 class="mt-6 text-3xl font-bold text-gray-900">Payment Failed</h1>
              <p class="mt-3 text-gray-600">
                We couldn't verify your payment. Please try again or contact support.
              </p>
              <p class="mt-2 text-sm text-gray-400">Reference: {@order.reference}</p>
              <div class="mt-8 flex gap-4">
                <a
                  href="/cart"
                  class="rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
                >
                  Return to Cart
                </a>
              </div>
            </div>
          <% _ -> %>
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Something went wrong</h1>
              <a href="/" class="mt-4 inline-block text-sm text-gray-500 underline">Go home</a>
            </div>
        <% end %>
      </div>

      <.footer />
    </div>
    """
  end
end
