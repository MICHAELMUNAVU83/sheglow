defmodule SheglowWeb.ProductComponents do
  @moduledoc "Components for the product detail page."
  use Phoenix.Component

  def product_detail(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <div class="grid gap-8 lg:grid-cols-2 lg:gap-12">
        <%!-- Left: Gallery --%>
        <div class="space-y-4">
          <div class="aspect-[3/4] overflow-hidden rounded-lg bg-gray-100">
            <img
              src={Enum.at(@product.gallery_images, @main_image_index) || @product.main_image}
              alt={@product.name}
              class="h-full w-full object-cover object-top object-top"
            />
          </div>
          <div class="flex gap-2">
            <%= for {img, idx} <- Enum.with_index(@product.gallery_images) do %>
              <button
                type="button"
                phx-click="set_main_image"
                phx-value-index={idx}
                class={"aspect-square w-20 flex-shrink-0 overflow-hidden rounded-lg border-2 bg-gray-100 transition #{if @main_image_index == idx, do: "border-black", else: "border-transparent hover:border-gray-300"}"}
              >
                <img src={img} alt="" class="h-full w-full object-cover object-top object-top" />
              </button>
            <% end %>
          </div>
        </div>

        <%!-- Right: Info --%>
        <div class="flex flex-col">
          <%!-- Reviews --%>
          <%= if (@product[:reviews_count] || 0) > 0 do %>
            <div class="flex items-center gap-2 text-sm text-gray-700">
              <div class="flex text-amber-400">
                <.rating_stars rating={@product.rating} />
              </div>
              <span>{"(#{@product.rating})"}</span>
              <span class="text-gray-400">|</span>
              <span class="text-gray-600">{"#{@product.reviews_count} reviews"}</span>
            </div>
          <% end %>

          <h1 class="mt-3 text-2xl font-bold text-black sm:text-3xl">{@product.name}</h1>
          <p class="mt-2 text-xl font-bold text-black">
            UGX {SheglowWeb.Format.price(@product.price)}
          </p>

          <%!-- Stock --%>
          <div class="mt-3 flex items-center gap-2 text-sm text-green-600">
            <span class="flex h-4 w-4 items-center justify-center rounded-full bg-green-500">
              <svg class="h-2.5 w-2.5 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                  clip-rule="evenodd"
                />
              </svg>
            </span>
            <span>In stock, ready for your routine</span>
          </div>

          <p class="mt-4 text-gray-700">{@product.description}</p>

          <%!-- Color --%>
          <div class="mt-6">
            <p class="text-sm font-semibold text-black">
              Formula
              <%= if @selected_color_id do %>
                <% selected = Enum.find(@product.colors, &(&1.id == @selected_color_id)) %>
                <%= if selected do %>
                  <span class="ml-1 font-normal text-gray-500">— {selected.name}</span>
                <% end %>
              <% end %>
            </p>
            <div class="mt-2 flex flex-wrap gap-2.5">
              <%= for color <- @product.colors do %>
                <button
                  type="button"
                  phx-click="select_color"
                  phx-value-id={color.id}
                  title={color.name}
                  class={[
                    "group relative flex h-9 w-9 items-center justify-center rounded-full border-2 transition",
                    if(@selected_color_id == color.id,
                      do: "border-gray-900 ring-2 ring-gray-900 ring-offset-2",
                      else: "border-transparent hover:border-gray-400"
                    )
                  ]}
                  style={"background-color: #{color.hex}"}
                >
                  <%= if @selected_color_id == color.id do %>
                    <svg class="h-3.5 w-3.5 drop-shadow" viewBox="0 0 20 20" fill="white">
                      <path
                        fill-rule="evenodd"
                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  <% end %>
                </button>
              <% end %>
            </div>
          </div>

          <%!-- Size --%>
          <div class="mt-4">
            <p class="text-sm font-semibold text-black">Size / Volume</p>
            <div class="mt-2 flex flex-wrap gap-2">
              <%= for size <- @product.sizes do %>
                <button
                  type="button"
                  phx-click="select_size"
                  phx-value-name={size.name}
                  disabled={not size.available}
                  class={"rounded-lg border-2 px-4 py-2 text-sm font-medium transition disabled:cursor-not-allowed disabled:opacity-50 #{if @selected_size_id == size.name, do: "border-black bg-black text-white", else: "border-gray-300 bg-white text-black hover:border-gray-400"}"}
                >
                  {size.name}
                </button>
              <% end %>
            </div>
          </div>

          <%!-- SKU & Type --%>
          <div class="mt-6 space-y-1 text-sm text-gray-700">
            <p class="flex items-center gap-2">
              <span class="h-1.5 w-1.5 rounded-full bg-black"></span>
              Category: {@product.product_type}
            </p>
          </div>

          <%!-- Chat CTA --%>
          <button
            type="button"
            phx-click="toggle_chat"
            class="mt-5 flex w-full items-center gap-3 rounded-xl border border-gray-200 bg-gray-50 px-4 py-3 text-left transition hover:border-gray-900 hover:bg-gray-100"
          >
            <span class="relative flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-full bg-gray-900 text-white">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
              <span class="absolute -right-0.5 -top-0.5 h-3 w-3 rounded-full bg-green-500 ring-2 ring-white">
              </span>
            </span>
            <div>
              <p class="text-sm font-semibold text-gray-900">Ask a Glow Advisor</p>
              <p class="text-xs text-gray-500">
                Questions about skin type, usage, or routine? We reply in minutes.
              </p>
            </div>
            <svg
              class="ml-auto h-4 w-4 flex-shrink-0 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>

          <%!-- Quantity & Add to Cart --%>
          <div class="mt-6 flex flex-wrap items-end gap-4">
            <form phx-change="set_quantity" class="flex flex-col">
              <label class="block text-sm font-semibold text-black">Quantity</label>
              <input
                type="number"
                name="quantity"
                min="1"
                max="99"
                value={@quantity}
                phx-debounce="300"
                class="mt-1 w-20 rounded-lg border border-gray-300 px-3 py-2 text-center text-black focus:border-gray-400 focus:outline-none"
              />
            </form>
            <button
              type="button"
              phx-click="add_to_cart"
              class="flex-1 rounded-full bg-black px-8 py-3 text-sm font-medium text-white transition hover:bg-gray-800 sm:flex-none"
            >
              Add to Cart
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def rating_stars(assigns) do
    rating_float = Decimal.to_float(assigns.rating)
    full = trunc(rating_float)
    has_half = rating_float - full >= 0.5
    assigns = assign(assigns, :full, full) |> assign(:has_half, has_half)

    ~H"""
    <%= for _i <- 1..@full do %>
      <svg class="h-5 w-5 fill-current" viewBox="0 0 20 20">
        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" />
      </svg>
    <% end %>
    <%= if @has_half do %>
      <svg class="h-5 w-5" viewBox="0 0 20 20">
        <defs>
          <linearGradient id={"product-half-#{@rating}"}>
            <stop offset="50%" stop-color="#FACC15" />
            <stop offset="50%" stop-color="#E5E7EB" />
          </linearGradient>
        </defs>
        <path
          fill={"url(#product-half-#{@rating})"}
          d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"
        />
      </svg>
    <% end %>
    <%= for _i <- 1..(5 - @full - if(@has_half, do: 1, else: 0)) do %>
      <svg class="h-5 w-5 fill-gray-200" viewBox="0 0 20 20">
        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" />
      </svg>
    <% end %>
    """
  end

  def product_accordions(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <div class="border-t border-gray-200">
        <.accordion_item
          id="product_info"
          title="Product Details"
          icon="info"
          open={@accordion_open == "product_info"}
          section="product_info"
        >
          <p class="pb-4 text-sm text-gray-700">
            {@product.description}
          </p>
        </.accordion_item>

        <%= if @product[:size_advice] not in [nil, ""] do %>
          <.accordion_item
            id="size_advice"
            title="Usage & Skin Match"
            icon="ruler"
            open={@accordion_open == "size_advice"}
            section="size_advice"
          >
            <p class="pb-4 text-sm text-gray-700">
              {@product.size_advice}
            </p>
          </.accordion_item>
        <% end %>

        <%= if @product[:shipping_returns] not in [nil, ""] do %>
          <.accordion_item
            id="shipping"
            title="Delivery & Returns"
            icon="info"
            open={@accordion_open == "shipping"}
            section="shipping"
          >
            <p class="pb-4 text-sm text-gray-700">
              {@product.shipping_returns}
            </p>
          </.accordion_item>
        <% end %>
      </div>
    </div>
    """
  end

  def accordion_item(assigns) do
    ~H"""
    <div class="border-b border-gray-200">
      <button
        type="button"
        phx-click="toggle_accordion"
        phx-value-section={@section}
        class="flex w-full items-center justify-between gap-4 py-4 text-left"
      >
        <div class="flex items-center gap-3">
          <%= if @icon == "info" do %>
            <span class="flex h-6 w-6 items-center justify-center rounded-full border border-gray-300 text-xs font-semibold text-gray-700">
              i
            </span>
          <% else %>
            <svg class="h-5 w-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"
              />
            </svg>
          <% end %>
          <span class="font-medium text-black">{@title}</span>
        </div>
        <svg
          class={"h-5 w-5 flex-shrink-0 text-gray-500 transition-transform #{if @open, do: "rotate-90"}"}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </button>
      <div class={if @open, do: "block", else: "hidden"}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  def related_products_section(assigns) do
    ~H"""
    <section class="border-t border-gray-200 bg-white px-4 py-12 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-7xl">
        <h2 class="text-center text-2xl font-bold text-gray-900 sm:text-3xl">Related Products</h2>
        <div class="relative mt-8">
          <button
            type="button"
            id="related-products-prev"
            class="related-products-nav-btn absolute -left-3 top-1/3 z-20 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-600 shadow-md transition hover:border-gray-900 hover:text-gray-900 sm:-left-5 xl:-left-12"
            aria-label="Previous"
          >
            <svg
              class="h-4 w-4"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            type="button"
            id="related-products-next"
            class="related-products-nav-btn absolute -right-3 top-1/3 z-20 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-600 shadow-md transition hover:border-gray-900 hover:text-gray-900 sm:-right-5 xl:-right-12"
            aria-label="Next"
          >
            <svg
              class="h-4 w-4"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          <div
            class="swiper related-products-swiper overflow-hidden"
            id="swiper-related-products"
            phx-hook="SwiperRelatedProducts"
          >
            <div class="swiper-wrapper">
              <%= for product <- @products do %>
                <div class="swiper-slide">
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
                        class="aspect-[3/4] w-full object-cover object-top object-top transition-transform duration-300 group-hover:scale-105"
                      />
                    </div>
                    <div class="mt-4 flex gap-2">
                      <%= for color <- product.colors do %>
                        <span
                          class={"inline-block h-5 w-5 rounded-full border-2 #{if color.selected, do: "border-gray-900", else: "border-transparent"}"}
                          style={"background-color: #{color.hex}"}
                        >
                        </span>
                      <% end %>
                    </div>
                    <h3 class="mt-3 text-sm font-medium text-gray-900">{product.name}</h3>
                    <div class="mt-1 flex items-center gap-2">
                      <span class={
                        if product.original_price,
                          do: "font-semibold text-red-500",
                          else: "font-semibold text-gray-900"
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
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end
end
