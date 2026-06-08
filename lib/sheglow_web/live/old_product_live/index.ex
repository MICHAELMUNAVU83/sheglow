defmodule SheglowWeb.OldProductLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.Shop
  alias Sheglow.Chat
  import SheglowWeb.ProductComponents
  import SheglowWeb.HomeComponents

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    product = Shop.get_product_by_slug(slug)

    if is_nil(product) do
      {:ok,
       socket
       |> put_flash(:error, "Product not found")
       |> push_navigate(to: "/")}
    else
      visitor_id = :crypto.strong_rand_bytes(12) |> Base.encode16(case: :lower)

      if connected?(socket), do: Chat.subscribe_visitor(visitor_id)

      related = Shop.list_related_products(product.id, 4)
      selected_color = product.colors |> Enum.find(& &1.selected) || List.first(product.colors)
      selected_size = product.sizes |> Enum.find(& &1.available) || List.first(product.sizes)
      selected_color_id = selected_color && selected_color.id
      selected_size_id = selected_size && selected_size.name

      hero_images = Shop.list_hero_images(6)

      {:ok,
       socket
       |> assign(:page_title, product.name)
       |> assign(
         :meta_description,
         "#{String.slice(product.description || "", 0, 150)} — Shop #{product.name} at SheGlow UG."
       )
       |> assign(:og_image, product.main_image || "/images/sheglow-logo.png")
       |> assign(:product, product)
       |> assign(:related_products, related)
       |> assign(:selected_color_id, selected_color_id)
       |> assign(:selected_size_id, selected_size_id)
       |> assign(:quantity, 1)
       |> assign(:main_image_index, 0)
       |> assign(:accordion_open, nil)
       |> assign(:contact_images, Enum.shuffle(hero_images))
       |> assign(:nav_collections, Shop.list_collections_for_display())
       # Chat assigns
       |> assign(:visitor_id, visitor_id)
       |> assign(:chat_open, false)
       |> assign(:chat_session_id, nil)
       |> assign(:chat_messages, [])
       |> assign(:chat_input, "")}
    end
  end

  # ── Product events ────────────────────────────────────────────────────────

  @impl true
  def handle_event("select_color", %{"id" => id}, socket) do
    {:noreply, assign(socket, :selected_color_id, id)}
  end

  @impl true
  def handle_event("select_size", %{"name" => name}, socket) do
    {:noreply, assign(socket, :selected_size_id, name)}
  end

  @impl true
  def handle_event("set_quantity", %{"quantity" => qty}, socket) do
    qty = max(1, min(99, String.to_integer(qty)))
    {:noreply, assign(socket, :quantity, qty)}
  end

  @impl true
  def handle_event("set_main_image", %{"index" => idx}, socket) do
    idx = String.to_integer(idx)
    max_idx = length(socket.assigns.product.gallery_images) - 1
    idx = max(0, min(idx, max_idx))
    {:noreply, assign(socket, :main_image_index, idx)}
  end

  @impl true
  def handle_event("toggle_accordion", %{"section" => section}, socket) do
    current = socket.assigns.accordion_open
    next = if current == section, do: nil, else: section
    {:noreply, assign(socket, :accordion_open, next)}
  end

  @impl true
  def handle_event("add_to_cart", _params, socket) do
    %{product: product, selected_color_id: color_id, selected_size_id: size, quantity: qty} =
      socket.assigns

    color = Enum.find(product.colors, fn c -> c.id == color_id end)

    item = %{
      id: product.id,
      slug: product.slug,
      name: product.name,
      image: product.main_image,
      price: product.price,
      color: color && color.name,
      color_id: color_id,
      size: size,
      quantity: qty
    }

    {:noreply, push_event(socket, "add-to-cart", item)}
  end

  @impl true
  def handle_event("contact_submit", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Thanks! We'll get back to you soon.")}
  end

  # ── Chat events ───────────────────────────────────────────────────────────

  @impl true
  def handle_event("restore_chat", %{"session_id" => session_id}, socket)
      when is_binary(session_id) and session_id != "" do
    case Chat.get_session(session_id) do
      nil ->
        {:noreply, socket}

      session ->
        if connected?(socket) do
          Chat.unsubscribe_visitor(socket.assigns.visitor_id)
          Chat.subscribe_visitor(session.visitor_id)
        end

        messages = Chat.list_messages(session.id)

        {:noreply,
         socket
         |> assign(:visitor_id, session.visitor_id)
         |> assign(:chat_session_id, session.id)
         |> assign(:chat_messages, messages)
         |> assign(:chat_open, true)
         |> push_event("chat-scroll", %{})}
    end
  end

  def handle_event("restore_chat", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("toggle_chat", _, socket) do
    {:noreply,
     socket
     |> assign(:chat_open, !socket.assigns.chat_open)
     |> push_event("chat-scroll", %{})}
  end

  @impl true
  def handle_event("update_chat_input", %{"msg" => text}, socket) do
    {:noreply, assign(socket, :chat_input, text)}
  end

  @impl true
  def handle_event("send_chat_message", params, socket) do
    text = String.trim(Map.get(params, "msg", ""))
    name = String.trim(Map.get(params, "visitor_name", ""))
    if text == "", do: {:noreply, socket}, else: do_send_chat(socket, text, name)
  end

  @impl true
  def handle_event("add_suggested_to_cart", params, socket) do
    item = %{
      id: params["product_id"],
      slug: params["slug"],
      name: params["name"],
      image: params["image"],
      price: params["price"],
      color: nil,
      size: nil,
      quantity: 1
    }

    {:noreply, push_event(socket, "add-to-cart", item)}
  end

  # ── PubSub handlers ───────────────────────────────────────────────────────

  @impl true
  def handle_info({:new_message, message}, socket) do
    if message.sender == "admin" do
      {:noreply,
       socket
       |> update(:chat_messages, fn msgs -> msgs ++ [message] end)
       |> assign(:chat_open, true)
       |> push_event("chat-scroll", %{})}
    else
      {:noreply, socket}
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp do_send_chat(socket, text, name) do
    %{
      visitor_id: visitor_id,
      chat_session_id: session_id,
      product: product
    } = socket.assigns

    {session_id, new_session?} =
      if session_id do
        {session_id, false}
      else
        {:ok, session} =
          Chat.get_or_create_session(visitor_id, %{
            product_id: product.id,
            product_name: product.name,
            product_slug: product.slug,
            visitor_name: if(name != "", do: name, else: "Visitor")
          })

        {session.id, true}
      end

    {:ok, message} =
      Chat.create_message(%{
        chat_session_id: session_id,
        sender: "visitor",
        content: text
      })

    messages = if new_session?, do: [message], else: socket.assigns.chat_messages ++ [message]

    {:noreply,
     socket
     |> assign(:chat_session_id, session_id)
     |> assign(:chat_messages, messages)
     |> assign(:chat_input, "")
     |> push_event("save-chat", %{session_id: session_id})
     |> push_event("chat-scroll", %{})}
  end

  defp format_time(dt) do
    Calendar.strftime(dt, "%H:%M")
  rescue
    _ -> ""
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="product-page" class="page-typography min-h-screen bg-white">
      <.navbar collections={@nav_collections} />
      <.product_detail
        product={@product}
        main_image_index={@main_image_index}
        selected_color_id={@selected_color_id}
        selected_size_id={@selected_size_id}
        quantity={@quantity}
      />
      <.product_accordions accordion_open={@accordion_open} product={@product} />
      <.related_products_section products={@related_products} />
      <.contact_section contact_images={@contact_images} />
      <.footer />

      <%!-- ── Floating Chat Widget ── --%>
      <div
        id="chat-widget"
        phx-hook="ChatPersist"
        class="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-3"
      >
        <%!-- Chat panel --%>
        <%= if @chat_open do %>
          <div
            id="chat-panel"
            class="flex h-[520px] w-[360px] flex-col overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-2xl"
          >
            <%!-- Header --%>
            <div class="flex items-center gap-3 bg-gray-900 px-4 py-3.5">
              <div class="flex h-8 w-8 items-center justify-center rounded-full bg-[#C8001F] text-white">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                  />
                </svg>
              </div>
              <div class="flex-1">
                <p class="text-sm font-semibold text-white">Ask a Sales Rep</p>
                <p class="text-[11px] text-gray-400">We reply in minutes</p>
              </div>
              <button
                phx-click="toggle_chat"
                class="rounded-lg p-1 text-gray-400 transition hover:bg-white/10 hover:text-white"
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

            <%!-- Messages --%>
            <div
              id="chat-messages-user"
              phx-hook="ChatScroll"
              class="flex-1 space-y-3 overflow-y-auto p-4"
            >
              <%= if Enum.empty?(@chat_messages) do %>
                <div class="py-6 text-center">
                  <p class="text-sm font-medium text-gray-700">👋 Hi there!</p>
                  <p class="mt-1 text-xs text-gray-400">
                    Ask us anything about sizes, colours or styling — we're here to help.
                  </p>
                </div>
              <% else %>
                <%= for msg <- @chat_messages do %>
                  <div class={[
                    "flex",
                    if(msg.sender == "visitor", do: "justify-end", else: "justify-start")
                  ]}>
                    <%= if msg.message_type == "product_suggestion" do %>
                      <div class="w-[220px]">
                        <div class="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-md">
                          <%= if msg.suggested_product_image do %>
                            <div class="relative h-40 w-full overflow-hidden bg-gray-50">
                              <img
                                src={msg.suggested_product_image}
                                class="h-full w-full object-cover object-top"
                              />
                            </div>
                          <% end %>
                          <div class="p-3">
                            <p class="text-[13px] font-semibold leading-snug text-gray-900">
                              {msg.suggested_product_name}
                            </p>
                            <p class="mt-1 text-sm font-bold text-gray-800">
                              UGX {SheglowWeb.Format.price(msg.suggested_product_price)}
                            </p>
                            <div class="mt-3 flex flex-col gap-2">
                              <button
                                type="button"
                                phx-click="add_suggested_to_cart"
                                phx-value-product_id={msg.suggested_product_id}
                                phx-value-slug={msg.suggested_product_slug}
                                phx-value-name={msg.suggested_product_name}
                                phx-value-image={msg.suggested_product_image}
                                phx-value-price={msg.suggested_product_price}
                                class="w-full rounded-xl bg-gray-900 py-2 text-center text-xs font-semibold text-white transition hover:bg-[#C8001F] active:scale-95"
                              >
                                Add to Cart
                              </button>
                              <a
                                href={"/products/#{msg.suggested_product_slug}"}
                                target="_blank"
                                rel="noopener noreferrer"
                                class="w-full rounded-xl border border-gray-200 py-2 text-center text-xs font-semibold text-gray-700 transition hover:border-gray-400 hover:text-gray-900"
                              >
                                View Product ↗
                              </a>
                            </div>
                          </div>
                        </div>
                        <p class="mt-1 text-[10px] text-gray-400">
                          {format_time(msg.inserted_at)}
                        </p>
                      </div>
                    <% else %>
                      <div class="max-w-[240px]">
                        <div class={[
                          "rounded-2xl px-3.5 py-2 text-sm",
                          if(msg.sender == "visitor",
                            do: "rounded-tr-sm bg-gray-900 text-white",
                            else: "rounded-tl-sm bg-gray-100 text-gray-800"
                          )
                        ]}>
                          {msg.content}
                        </div>
                        <p class={[
                          "mt-0.5 text-[10px] text-gray-400",
                          if(msg.sender == "visitor", do: "text-right", else: "text-left")
                        ]}>
                          {format_time(msg.inserted_at)}
                        </p>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              <% end %>
            </div>

            <%!-- Input --%>
            <div class="border-t border-gray-100 p-3">
              <.form for={%{}} phx-submit="send_chat_message" class="space-y-2">
                <%!-- Name field — inside the form so it's never reset by re-renders --%>
                <%= if @chat_session_id == nil do %>
                  <input
                    type="text"
                    name="visitor_name"
                    placeholder="Your name (optional) — e.g. Jane"
                    maxlength="40"
                    autocomplete="name"
                    class="w-full rounded-xl border border-gray-200 bg-gray-50 px-3.5 py-2 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:bg-white focus:outline-none"
                  />
                <% end %>
                <div class="flex items-center gap-2">
                  <input
                    type="text"
                    name="msg"
                    value={@chat_input}
                    phx-change="update_chat_input"
                    placeholder="Type a message…"
                    autocomplete="off"
                    class="flex-1 rounded-xl border border-gray-200 bg-gray-50 px-3.5 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:bg-white focus:outline-none"
                  />
                  <button
                    type="submit"
                    class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-gray-900 text-white transition hover:bg-gray-700"
                  >
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                      />
                    </svg>
                  </button>
                </div>
              </.form>
            </div>
          </div>
        <% end %>

        <%!-- Toggle button --%>
        <div class="relative">
          <%!-- Pulse ring (only when closed) --%>
          <%= if !@chat_open do %>
            <span class="absolute inset-0 animate-ping rounded-full bg-gray-900 opacity-20"></span>
          <% end %>
          <button
            phx-click="toggle_chat"
            class="relative flex h-14 w-14 items-center justify-center rounded-full bg-gray-900 text-white shadow-xl transition hover:bg-[#C8001F]"
            aria-label="Chat with us"
          >
            <%= if @chat_open do %>
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            <% else %>
              <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
            <% end %>
          </button>
          <%!-- Unread badge --%>
          <% unread = length(Enum.filter(@chat_messages, &(&1.sender == "admin"))) %>
          <%= if unread > 0 and !@chat_open do %>
            <span class="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-[#C8001F] text-[10px] font-bold text-white ring-2 ring-white">
              {unread}
            </span>
          <% end %>
          <%!-- "Chat" label (when closed and no messages yet) --%>
          <%= if !@chat_open and length(@chat_messages) == 0 do %>
            <span class="absolute -left-16 top-1/2 -translate-y-1/2 whitespace-nowrap rounded-lg bg-gray-900 px-2.5 py-1 text-xs font-semibold text-white shadow-lg">
              Chat
            </span>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
