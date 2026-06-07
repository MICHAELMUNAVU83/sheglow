defmodule SheglowWeb.AdminChatLive.Show do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Chat

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    session = Chat.get_session!(id)
    messages = Chat.list_messages(id)

    if connected?(socket) do
      Chat.subscribe_admin_session(id)
      Chat.mark_read_by_admin(id)
    end

    {:ok,
     socket
     |> assign(:page_title, "Chat — #{session.visitor_name || "Visitor"}")
     |> assign(:current_path, "/admin/chat")
     |> assign(:session, session)
     |> assign(:messages, messages)
     |> assign(:reply_text, "")
     |> assign(:product_query, "")
     |> assign(:product_results, [])
     |> assign(:show_product_search, false)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    Chat.mark_read_by_admin(socket.assigns.session.id)
    {:noreply,
     socket
     |> update(:messages, fn msgs -> msgs ++ [message] end)
     |> push_event("chat-scroll", %{})}
  end

  # ── Events ────────────────────────────────────────────────────────────────

  @impl true
  def handle_event("send_reply", %{"reply" => text}, socket) when byte_size(text) > 0 do
    %{session: session} = socket.assigns
    trimmed = String.trim(text)

    if trimmed != "" do
      Chat.create_message(%{
        chat_session_id: session.id,
        sender: "admin",
        content: trimmed,
        message_type: "text"
      })
    end

    {:noreply,
     socket
     |> assign(:reply_text, "")
     |> push_event("chat-scroll", %{})}
  end

  def handle_event("send_reply", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("update_reply", %{"reply" => text}, socket) do
    {:noreply, assign(socket, :reply_text, text)}
  end

  @impl true
  def handle_event("toggle_product_search", _, socket) do
    {:noreply,
     socket
     |> assign(:show_product_search, !socket.assigns.show_product_search)
     |> assign(:product_query, "")
     |> assign(:product_results, [])}
  end

  @impl true
  def handle_event("search_products", %{"q" => q}, socket) do
    results = Chat.search_products(q)
    {:noreply, assign(socket, product_results: results, product_query: q)}
  end

  def handle_event("search_products", %{"value" => q}, socket) do
    results = Chat.search_products(q)
    {:noreply, assign(socket, product_results: results, product_query: q)}
  end

  @impl true
  def handle_event("suggest_product", %{"id" => pid_str}, socket) do
    %{session: session} = socket.assigns

    case Integer.parse(pid_str) do
      {pid, _} ->
        product = Sheglow.Products.get_product!(pid)
        price_decimal = Decimal.new(product.base_price)

        Chat.create_message(%{
          chat_session_id: session.id,
          sender: "admin",
          content: "I think you'd love this one! 👇",
          message_type: "product_suggestion",
          suggested_product_id: product.id,
          suggested_product_name: product.name,
          suggested_product_price: price_decimal,
          suggested_product_image: product.image,
          suggested_product_slug: product.slug
        })

        {:noreply,
         socket
         |> assign(:show_product_search, false)
         |> assign(:product_results, [])
         |> assign(:product_query, "")
         |> push_event("chat-scroll", %{})}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("close_session", _, socket) do
    {:ok, session} = Chat.update_session(socket.assigns.session, %{status: "closed"})
    {:noreply, assign(socket, :session, session)}
  end

  @impl true
  def handle_event("reopen_session", _, socket) do
    {:ok, session} = Chat.update_session(socket.assigns.session, %{status: "active"})
    {:noreply, assign(socket, :session, session)}
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp format_time(dt) do
    dt
    |> DateTime.shift_zone!("Africa/Nairobi")
    |> Calendar.strftime("%I:%M %p")
  rescue
    _ -> Calendar.strftime(dt, "%H:%M")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Page header --%>
    <div class="mb-6 flex items-center justify-between">
      <div class="flex items-center gap-4">
        <.link navigate={~p"/admin/chat"}>
          <button class="flex h-10 w-10 items-center justify-center rounded-xl border border-gray-200 text-gray-400 transition hover:border-gray-300 hover:text-gray-700">
            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
        </.link>
        <div>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Live Chat</p>
          <h1 class="mt-0.5 text-2xl font-bold text-gray-900">
            {(@session.visitor_name || "Visitor")}
            <%= if @session.product_name do %>
              <span class="text-sm font-normal text-gray-400">— re: {@session.product_name}</span>
            <% end %>
          </h1>
        </div>
      </div>

      <div class="flex items-center gap-2">
        <%= if @session.status != "closed" do %>
          <button
            phx-click="close_session"
            data-confirm="Close this chat session?"
            class="rounded-xl border border-gray-200 px-4 py-2 text-sm font-semibold text-gray-600 transition hover:border-gray-300 hover:text-gray-900"
          >
            Close Chat
          </button>
        <% else %>
          <span class="rounded-full bg-gray-100 px-3 py-1.5 text-xs font-semibold text-gray-500">
            Closed
          </span>
          <button
            phx-click="reopen_session"
            class="rounded-xl bg-gray-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-gray-700"
          >
            Reopen
          </button>
        <% end %>
      </div>
    </div>

    <%!-- Chat area --%>
    <div class="flex h-[calc(100vh-220px)] flex-col overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <%!-- Messages --%>
      <div
        id="chat-messages"
        phx-hook="ChatScroll"
        class="flex-1 space-y-4 overflow-y-auto p-6"
      >
        <%= if Enum.empty?(@messages) do %>
          <p class="text-center text-sm text-gray-400">No messages yet.</p>
        <% else %>
          <%= for msg <- @messages do %>
            <div class={[
              "flex",
              if(msg.sender == "admin", do: "justify-end", else: "justify-start")
            ]}>
              <%= if msg.message_type == "product_suggestion" do %>
                <%!-- Product suggestion card --%>
                <div class="max-w-xs space-y-2">
                  <p class="text-xs text-gray-400">
                    <%= if msg.sender == "admin", do: "You suggested", else: "Sales rep suggested" %>
                  </p>
                  <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
                    <%= if msg.suggested_product_image do %>
                      <img
                        src={msg.suggested_product_image}
                        alt={msg.suggested_product_name}
                        class="h-40 w-full object-cover object-top"
                      />
                    <% end %>
                    <div class="p-3">
                      <p class="text-sm font-semibold text-gray-900">{msg.suggested_product_name}</p>
                      <p class="mt-0.5 text-sm font-bold text-gray-700">
                        KES {SheglowWeb.Format.price(msg.suggested_product_price)}
                      </p>
                      <a
                        href={"/products/#{msg.suggested_product_slug}"}
                        target="_blank"
                        class="mt-2 block w-full rounded-lg bg-gray-900 py-1.5 text-center text-xs font-semibold text-white transition hover:bg-gray-700"
                      >
                        View Product →
                      </a>
                    </div>
                  </div>
                  <p class="text-right text-[10px] text-gray-400">{format_time(msg.inserted_at)}</p>
                </div>
              <% else %>
                <%!-- Regular text bubble --%>
                <div class="max-w-xs lg:max-w-md">
                  <div class={[
                    "rounded-2xl px-4 py-2.5 text-sm",
                    if(msg.sender == "admin",
                      do: "rounded-tr-sm bg-gray-900 text-white",
                      else: "rounded-tl-sm bg-gray-100 text-gray-900"
                    )
                  ]}>
                    {msg.content}
                  </div>
                  <p class={[
                    "mt-1 text-[10px] text-gray-400",
                    if(msg.sender == "admin", do: "text-right", else: "text-left")
                  ]}>
                    {format_time(msg.inserted_at)}
                  </p>
                </div>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>

      <%!-- Product search panel --%>
      <%= if @show_product_search do %>
        <div class="border-t border-gray-100 bg-gray-50 p-4">
          <p class="mb-2 text-xs font-semibold uppercase tracking-widest text-gray-400">
            Suggest a Product
          </p>
          <form phx-change="search_products" phx-submit="search_products">
          <input
            type="text"
            value={@product_query}
            placeholder="Search products by name…"
            name="q"
            autofocus
            phx-debounce="200"
            class="w-full rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm focus:border-gray-400 focus:outline-none"
          />
          </form>
          <%= if @product_results != [] do %>
            <div class="mt-3 space-y-2">
              <%= for p <- @product_results do %>
                <div class="flex items-center gap-3 rounded-xl border border-gray-200 bg-white p-3">
                  <%= if p.image do %>
                    <img src={p.image} class="h-12 w-12 flex-shrink-0 rounded-lg object-cover object-top" />
                  <% end %>
                  <div class="min-w-0 flex-1">
                    <p class="truncate text-sm font-semibold text-gray-900">{p.name}</p>
                    <p class="text-xs text-gray-500">KES {SheglowWeb.Format.price(p.base_price)}</p>
                  </div>
                  <button
                    phx-click="suggest_product"
                    phx-value-id={p.id}
                    class="flex-shrink-0 rounded-lg bg-gray-900 px-3 py-1.5 text-xs font-semibold text-white transition hover:bg-gray-700"
                  >
                    Suggest
                  </button>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>

      <%!-- Reply input --%>
      <div class="border-t border-gray-100 p-4">
        <.form
          for={%{}}
          phx-submit="send_reply"
          class="flex items-end gap-3"
        >
          <div class="flex-1">
            <textarea
              name="reply"
              rows="2"
              placeholder="Type your reply…"
              value={@reply_text}
              phx-change="update_reply"
              disabled={@session.status == "closed"}
              class="w-full resize-none rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm text-gray-900 placeholder-gray-400 transition focus:border-gray-400 focus:bg-white focus:outline-none disabled:opacity-50"
            >{@reply_text}</textarea>
          </div>
          <div class="flex flex-col gap-2">
            <button
              type="button"
              phx-click="toggle_product_search"
              title="Suggest a product"
              class={[
                "flex h-10 w-10 items-center justify-center rounded-xl border transition",
                if(@show_product_search,
                  do: "border-gray-900 bg-gray-900 text-white",
                  else: "border-gray-200 text-gray-400 hover:border-gray-400 hover:text-gray-700"
                )
              ]}
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </button>
            <button
              type="submit"
              disabled={@session.status == "closed"}
              class="flex h-10 w-10 items-center justify-center rounded-xl bg-gray-900 text-white transition hover:bg-gray-700 disabled:opacity-40"
            >
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
