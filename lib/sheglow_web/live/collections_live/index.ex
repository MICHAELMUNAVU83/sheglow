defmodule SheglowWeb.CollectionsLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.Shop

  @impl true
  def mount(_params, _session, socket) do
    collections = Shop.list_collections_for_display()

    {:ok,
     socket
     |> assign(:page_title, "All Categories — SheGlow UG")
     |> assign(:collections, collections)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <.navbar collections={@collections} />

      <%!-- Hero strip --%>
      <div class="bg-[#f5f5f3]">
        <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
          <a
            href="/"
            class="inline-flex items-center gap-1 text-xs font-medium text-gray-400 hover:text-gray-700 transition mb-6"
          >
            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Home
          </a>
          <p class="text-xs font-semibold uppercase tracking-widest text-[#C8001F]">
            Fashion's Gallery
          </p>
          <h1 class="mt-2 text-4xl font-bold text-gray-900 sm:text-5xl">All Collections</h1>
          <p class="mt-3 text-sm text-gray-500">
            {length(@collections)} curated collections — find your style.
          </p>
        </div>
      </div>

      <%!-- Collections grid --%>
      <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div class="grid gap-5 w-[100%] sm:grid-cols-2 lg:grid-cols-3">
          <%= for {collection, index} <- Enum.with_index(@collections, 1) do %>
            <a
              href={collection.href}
              class="group relative overflow-hidden rounded-2xl bg-gray-100 transition hover:shadow-xl"
            >
              <%!-- Cover image --%>
              <%= if collection.image not in [nil, ""] do %>
                <img
                  src={collection.image}
                  alt={collection.name}
                  class="aspect-[4/3] w-full object-cover object-top transition-transform duration-500 group-hover:scale-105"
                />
              <% else %>
                <div class="aspect-[4/3] w-full bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center">
                  <span class="text-5xl opacity-30">👗</span>
                </div>
              <% end %>

              <%!-- Gradient overlay --%>
              <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />

              <%!-- Text --%>
              <div class="absolute inset-x-0 bottom-0 p-5">
                <span class="text-xs font-semibold text-white/50">
                  {String.pad_leading("#{index}", 2, "0")}
                </span>
                <h2 class="mt-1 text-xl font-bold text-white leading-tight">{collection.name}</h2>
                <div class="mt-2 flex items-center justify-between">
                  <span class="text-xs text-white/70">{collection.item_count} items</span>
                  <span class="inline-flex items-center gap-1 rounded-full bg-white/20 px-3 py-1 text-xs font-semibold text-white backdrop-blur-sm transition group-hover:bg-[#C8001F]">
                    Shop
                    <svg
                      class="h-3 w-3 transition-transform group-hover:translate-x-0.5"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 8l4 4m0 0l-4 4m4-4H3"
                      />
                    </svg>
                  </span>
                </div>
              </div>
            </a>
          <% end %>
        </div>

        <%= if @collections == [] do %>
          <div class="flex flex-col items-center justify-center py-24 text-center">
            <span class="text-6xl">🛍️</span>
            <p class="mt-4 text-lg font-semibold text-gray-700">No collections yet</p>
            <p class="mt-1 text-sm text-gray-400">Check back soon — new styles drop monthly.</p>
          </div>
        <% end %>
      </div>

      <.footer />
    </div>
    """
  end
end
