defmodule SheglowWeb.AdminChatLive.Index do
  use SheglowWeb, :admin_live_view

  alias Sheglow.Chat

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe_admin()

    sessions = Chat.list_sessions()

    {:ok,
     socket
     |> assign(:page_title, "Chat")
     |> assign(:current_path, "/admin/chat")
     |> assign(:sessions, sessions)
     |> assign(:filter, "open")}
  end

  @impl true
  def handle_info({:new_message, %{session: session, message: _message}}, socket) do
    sessions =
      socket.assigns.sessions
      |> Enum.map(fn s ->
        if s.id == session.id, do: %{s | last_message_at: session.last_message_at, status: "active"}, else: s
      end)
      |> then(fn list ->
        if Enum.any?(list, &(&1.id == session.id)) do
          list
        else
          [session | list]
        end
      end)

    {:noreply, assign(socket, :sessions, sessions)}
  end

  @impl true
  def handle_event("set_filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, :filter, filter)}
  end

  defp filtered_sessions(sessions, "open") do
    Enum.filter(sessions, &(&1.status in ["open", "active"]))
  end

  defp filtered_sessions(sessions, "closed") do
    Enum.filter(sessions, &(&1.status == "closed"))
  end

  defp filtered_sessions(sessions, _), do: sessions

  defp time_ago(nil), do: "—"

  defp time_ago(dt) do
    diff = DateTime.diff(DateTime.utc_now(), dt, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      true -> "#{div(diff, 86400)}d ago"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mb-8 flex items-center justify-between">
      <div>
        <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Support</p>
        <h1 class="mt-0.5 text-3xl font-bold text-gray-900">Live Chat</h1>
      </div>
      <div class="flex items-center gap-2 rounded-xl border border-gray-200 bg-white p-1">
        <%= for {label, val} <- [{"Active", "open"}, {"Closed", "closed"}, {"All", "all"}] do %>
          <button
            phx-click="set_filter"
            phx-value-filter={val}
            class={[
              "rounded-lg px-4 py-1.5 text-sm font-semibold transition",
              if(@filter == val,
                do: "bg-gray-900 text-white",
                else: "text-gray-500 hover:text-gray-900"
              )
            ]}
          >
            {label}
            <span class="ml-1 text-xs opacity-60">
              {length(filtered_sessions(@sessions, val))}
            </span>
          </button>
        <% end %>
      </div>
    </div>

    <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white">
      <% visible = filtered_sessions(@sessions, @filter) %>
      <%= if Enum.empty?(visible) do %>
        <div class="flex flex-col items-center justify-center py-20 text-center">
          <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100">
            <svg class="h-7 w-7 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>
          <p class="mt-4 text-base font-semibold text-gray-700">No chats yet</p>
          <p class="mt-1.5 text-sm text-gray-400">Visitor conversations will appear here in real-time.</p>
        </div>
      <% else %>
        <div class="divide-y divide-gray-100">
          <%= for session <- visible do %>
            <.link
              navigate={~p"/admin/chat/#{session.id}"}
              class="flex items-center gap-4 px-6 py-4 transition hover:bg-gray-50"
            >
              <%!-- Avatar --%>
              <div class={[
                "flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full text-sm font-bold text-white",
                if(session.status in ["open", "active"], do: "bg-[#C8001F]", else: "bg-gray-400")
              ]}>
                {String.first(session.visitor_name || "?") |> String.upcase()}
              </div>

              <%!-- Info --%>
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-2">
                  <p class="truncate text-sm font-semibold text-gray-900">
                    {session.visitor_name || "Visitor"}
                  </p>
                  <%= if session.status in ["open", "active"] do %>
                    <span class="inline-flex h-2 w-2 flex-shrink-0 rounded-full bg-green-500"></span>
                  <% end %>
                </div>
                <%= if session.product_name do %>
                  <p class="mt-0.5 truncate text-xs text-gray-400">
                    Re: {session.product_name}
                  </p>
                <% end %>
              </div>

              <%!-- Time + badge --%>
              <div class="flex flex-shrink-0 flex-col items-end gap-1">
                <span class="text-xs text-gray-400">{time_ago(session.last_message_at)}</span>
                <%= if session.status == "open" do %>
                  <span class="inline-flex items-center rounded-full bg-[#C8001F] px-2 py-0.5 text-[10px] font-bold text-white">
                    New
                  </span>
                <% end %>
              </div>
            </.link>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
