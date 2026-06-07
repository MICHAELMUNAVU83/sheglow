defmodule SheglowWeb.CategoryComponents do
  @moduledoc "Components for the category/collection page: promo bar, hero, filters, product grid."
  use Phoenix.Component

  def category_hero(assigns) do
    ~H"""
    <section class="relative flex min-h-[280px] items-center justify-center bg-black sm:min-h-[320px] lg:min-h-[380px]">
      <img
        src={@category.hero_image}
        alt=""
        class="absolute inset-0 h-full w-full object-cover object-top opacity-50"
      />
      <div class="absolute inset-0 bg-black/40" aria-hidden="true"></div>
      <div class="relative z-10 px-4 text-center text-white">
        <p class="text-xs font-semibold uppercase tracking-widest opacity-90">{@category.subtitle}</p>
        <h1 class="mt-2 text-3xl font-bold sm:text-4xl lg:text-5xl">{@category.title}</h1>
      </div>
    </section>
    """
  end

  def category_main(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <div class="flex flex-col gap-8 lg:flex-row">
        <%!-- Sidebar: desktop always visible; mobile as drawer --%>
        <aside
          id="category-sidebar"
          class={"category-sidebar fixed inset-y-0 left-0 z-40 w-72 transform border-r border-gray-200 bg-white shadow-xl transition-transform duration-200 ease-out lg:static lg:z-0 lg:block lg:w-64 lg:shrink-0 lg:border-r lg:shadow-none xl:w-72 #{if @filters_open, do: "translate-x-0", else: "-translate-x-full lg:translate-x-0"}"}
        >
          <div class="flex h-full flex-col overflow-y-auto py-6 pl-6 pr-4">
            <div class="flex items-center justify-between border-b border-gray-100 pb-4 lg:border-0 lg:pb-0">
              <h2 class="text-lg font-semibold text-black lg:sr-only">Filters</h2>
              <button
                type="button"
                phx-click="close_filters"
                class="rounded p-2 text-gray-500 hover:bg-gray-100 lg:hidden"
                aria-label="Close filters"
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
            <.product_type_filters product_types={@product_types} selected_types={@selected_types} />
            <.popular_products_block products={@popular_products} class="mt-8" />
          </div>
        </aside>
        <%!-- Overlay when sidebar open on mobile --%>
        <div
          :if={@filters_open}
          phx-click="close_filters"
          class="fixed inset-0 z-30 bg-black/20 lg:hidden"
          aria-hidden="true"
        >
        </div>
        <%!-- Main: toolbar + grid --%>
        <main class="min-w-0 flex-1">
          <.category_toolbar
            filter_pill={@filter_pill}
            sort={@sort}
            on_toggle_filters="toggle_filters"
          />
          <.product_grid products={@products} class="mt-6" />
        </main>
      </div>
    </div>
    """
  end

  def product_type_filters(assigns) do
    ~H"""
    <div class={assigns[:class]}>
      <h3 class="text-sm font-semibold text-black">Product Type</h3>
      <ul class="mt-3 space-y-2" role="list">
        <%= for pt <- @product_types do %>
          <li>
            <button
              type="button"
              phx-click="toggle_product_type"
              phx-value-slug={pt.slug}
              class="flex w-full items-center gap-3 rounded py-2 text-left text-sm text-gray-700 hover:text-black"
            >
              <span
                class={"flex h-4 w-4 flex-shrink-0 items-center justify-center rounded border border-gray-300 #{if pt.slug in @selected_types, do: "bg-black", else: "bg-white"}"}
                aria-hidden="true"
              >
                <%= if pt.slug in @selected_types do %>
                  <svg class="h-2.5 w-2.5 text-white" fill="currentColor" viewBox="0 0 12 12">
                    <path d="M10.28 2.28L3.989 8.575 1.695 6.28A1 1 0 00.28 7.695l3 3a1 1 0 001.414 0l7-7A1 1 0 0010.28 2.28z" />
                  </svg>
                <% end %>
              </span>
              <span>{pt.name}</span>
            </button>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def popular_products_block(assigns) do
    ~H"""
    <div class={assigns[:class]}>
      <h3 class="text-sm font-semibold text-black">Popular Products</h3>
      <ul class="mt-3 space-y-4" role="list">
        <%= for product <- @products do %>
          <li>
            <a href={product.href} class="flex gap-3">
              <div class="h-16 w-16 flex-shrink-0 overflow-hidden rounded bg-gray-100">
                <img src={product.image} alt="" class="h-full w-full object-cover" />
              </div>
              <div class="min-w-0 flex-1">
                <p class="truncate text-sm font-medium text-black">{product.name}</p>
                <p class="text-sm text-gray-700">UGX {SheglowWeb.Format.price(product.price)}</p>
                <div class="mt-0.5 flex items-center gap-1">
                  <%= for _ <- 1..5 do %>
                    <svg class="h-4 w-4 text-amber-400" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                    </svg>
                  <% end %>
                  <span class="ml-1 text-xs text-gray-700">({product.rating})</span>
                </div>
              </div>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def category_toolbar(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
      <div class="flex flex-wrap items-center gap-3">
        <button
          type="button"
          phx-click="toggle_filters"
          class="flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 lg:hidden"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
            />
          </svg>
          Filters
        </button>
        <div class="flex flex-wrap gap-2">
          <button
            type="button"
            phx-click="set_filter_pill"
            phx-value-pill="all"
            class={"rounded-full border px-4 py-2 text-sm font-medium transition #{if @filter_pill == "all", do: "border-gray-400 bg-gray-100 text-black", else: "border-gray-300 bg-white text-gray-700 hover:bg-gray-50"}"}
          >
            All
          </button>
          <button
            type="button"
            phx-click="set_filter_pill"
            phx-value-pill="on_sale"
            class={"rounded-full border px-4 py-2 text-sm font-medium transition #{if @filter_pill == "on_sale", do: "border-gray-400 bg-gray-100 text-black", else: "border-gray-300 bg-white text-gray-700 hover:bg-gray-50"}"}
          >
            On Sale
          </button>
          <button
            type="button"
            phx-click="set_filter_pill"
            phx-value-pill="discounts"
            class={"rounded-full border px-4 py-2 text-sm font-medium transition #{if @filter_pill == "discounts", do: "border-gray-400 bg-gray-100 text-black", else: "border-gray-300 bg-white text-gray-700 hover:bg-gray-50"}"}
          >
            Discounts
          </button>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-sm text-gray-700">Sort by:</span>
        <form phx-change="set_sort" class="relative inline-block">
          <select
            name="sort"
            class="appearance-none rounded-lg border border-gray-300 bg-white py-2 pl-4 pr-10 text-sm font-medium text-black focus:border-gray-400 focus:outline-none"
          >
            <option value="best_selling" selected={@sort == "best_selling"}>Best Selling</option>
            <option value="newest" selected={@sort == "newest"}>Newest</option>
            <option value="price_asc" selected={@sort == "price_asc"}>Price: Low to High</option>
            <option value="price_desc" selected={@sort == "price_desc"}>Price: High to Low</option>
          </select>
          <svg
            class="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </form>
      </div>
    </div>
    """
  end

  def product_grid(assigns) do
    assigns = assign_new(assigns, :class, fn -> "" end)

    ~H"""
    <ul class={"grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 #{@class}"} role="list">
      <%= for product <- @products do %>
        <li>
          <a href={"/products/#{product.slug}"} class="group block">
            <div class="relative overflow-hidden rounded-lg bg-gray-100">
              <%= if product.badge do %>
                <span class={"absolute left-3 top-3 z-10 rounded px-2 py-1 text-xs font-semibold text-white #{if product.badge == "Sale", do: "bg-green-600", else: "bg-red-500"}"}>
                  {product.badge}
                </span>
              <% end %>
              <img
                src={product.main_image}
                alt={product.name}
                class="aspect-[3/4] w-full object-cover object-top transition-transform duration-300 group-hover:scale-105"
              />
            </div>
            <div class="mt-4 flex gap-2">
              <%= for color <- product.colors do %>
                <span
                  class={"inline-block h-5 w-5 rounded-full border-2 #{if color.selected, do: "border-black", else: "border-transparent"}"}
                  style={"background-color: #{color.hex}"}
                  aria-hidden="true"
                >
                </span>
              <% end %>
            </div>
            <h3 class="mt-3 text-sm font-medium text-black">{product.name}</h3>
            <div class="mt-1 flex items-center gap-2">
              <span class={
                if product.original_price,
                  do: "font-semibold text-red-500",
                  else: "font-semibold text-black"
              }>
                UGX {SheglowWeb.Format.price(product.price)}
              </span>
              <%= if product.original_price do %>
                <span class="text-sm text-gray-400 line-through">
                  UGX {SheglowWeb.Format.price(product.original_price)}
                </span>
              <% end %>
            </div>
          </a>
        </li>
      <% end %>
    </ul>
    """
  end
end
