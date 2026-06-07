defmodule SheglowWeb.BundleShowLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.Shop
  alias Sheglow.ProductVariants

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Shop.get_bundle_for_display(id) do
      nil ->
        {:ok, push_navigate(socket, to: "/")}

      bundle ->
        product_ids = Enum.map(bundle.products, & &1.id)
        variants_by_product = ProductVariants.list_variants_for_products(product_ids)

        # Default selection: first color + first size per product
        selected_variants =
          Map.new(bundle.products, fn p ->
            variants = Map.get(variants_by_product, p.id, [])
            first = List.first(variants)

            selection = %{
              color_name: (first && first.color_name) || "",
              color_hex: (first && first.color_hex) || "#000000",
              color_id: (first && "c1") || "",
              size: (first && first.size) || ""
            }

            {p.id, selection}
          end)

        total = bundle.products |> Enum.reduce(0, fn p, acc -> acc + (p.price || 0) end)

        {:ok,
         socket
         |> assign(:page_title, "#{bundle.title} — Bundle & Save")
         |> assign(:bundle, bundle)
         |> assign(:bundle_total, total)
         |> assign(:variants_by_product, variants_by_product)
         |> assign(:selected_variants, selected_variants)}
    end
  end

  @impl true
  def handle_event(
        "select_color",
        %{
          "product_id" => pid_str,
          "color" => color_name,
          "color_id" => color_id,
          "color_hex" => color_hex
        },
        socket
      ) do
    pid = String.to_integer(pid_str)

    # Find first available size for this color
    first_size =
      socket.assigns.variants_by_product
      |> Map.get(pid, [])
      |> Enum.find(&(&1.color_name == color_name))
      |> then(&((&1 && &1.size) || ""))

    updated =
      Map.update(socket.assigns.selected_variants, pid, %{}, fn sel ->
        %{
          sel
          | color_name: color_name,
            color_id: color_id,
            color_hex: color_hex,
            size: first_size
        }
      end)

    {:noreply, assign(socket, :selected_variants, updated)}
  end

  @impl true
  def handle_event("select_size", %{"product_id" => pid_str, "size" => size}, socket) do
    pid = String.to_integer(pid_str)

    updated =
      Map.update(socket.assigns.selected_variants, pid, %{}, fn sel ->
        %{sel | size: size}
      end)

    {:noreply, assign(socket, :selected_variants, updated)}
  end

  # Add a single product to cart via CartHook event
  @impl true
  def handle_event("add_to_cart", %{"product_id" => pid_str}, socket) do
    pid = String.to_integer(pid_str)
    product = Enum.find(socket.assigns.bundle.products, &(&1.id == pid))
    sel = Map.get(socket.assigns.selected_variants, pid, %{})

    if product do
      item = %{
        id: product.id,
        name: product.name,
        slug: product.slug,
        price: product.price,
        image: product.main_image,
        color: sel[:color_name] || "",
        color_id: sel[:color_id] || "",
        color_hex: sel[:color_hex] || "",
        size: sel[:size] || ""
      }

      {:noreply, push_event(socket, "add-to-cart", item)}
    else
      {:noreply, socket}
    end
  end

  # Add all products to cart
  @impl true
  def handle_event("add_all_to_cart", _params, socket) do
    items =
      Enum.map(socket.assigns.bundle.products, fn p ->
        sel = Map.get(socket.assigns.selected_variants, p.id, %{})

        %{
          id: p.id,
          name: p.name,
          slug: p.slug,
          price: p.price,
          image: p.main_image,
          color: sel[:color_name] || "",
          color_id: sel[:color_id] || "",
          color_hex: sel[:color_hex] || "",
          size: sel[:size] || ""
        }
      end)

    # Push each item via the CartHook "add-to-cart" event
    socket =
      Enum.reduce(items, socket, fn item, acc ->
        push_event(acc, "add-to-cart", item)
      end)

    {:noreply, push_event(socket, "navigate-to-cart", %{})}
  end

  # --- Helpers ---

  defp colors_for(variants_by_product, product_id) do
    (variants_by_product[product_id] || [])
    |> Enum.filter(&(&1.color_name not in [nil, ""]))
    |> Enum.uniq_by(& &1.color_name)
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} ->
      %{name: v.color_name, hex: v.color_hex || "#000000", id: "c#{idx + 1}"}
    end)
  end

  defp sizes_for(variants_by_product, product_id, color_name) do
    (variants_by_product[product_id] || [])
    |> Enum.filter(&(&1.color_name == color_name and &1.size not in [nil, ""]))
    |> Enum.map(& &1.size)
    |> Enum.uniq()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#f5f5f3]" id="bundle-show-page" phx-hook="CartHook">
      <.bundle_navbar />

      <%!-- Header --%>
      <div class="bg-white border-b border-gray-100">
        <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
          <a
            href="/"
            class="inline-flex items-center gap-1 text-xs font-medium text-gray-400 hover:text-gray-700 transition mb-4"
          >
            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Home
          </a>

          <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p class="text-xs font-semibold uppercase tracking-widest text-[#C8001F]">
                Bundle & Save
              </p>
              <h1 class="mt-1 text-3xl font-bold text-gray-900 sm:text-4xl">{@bundle.title}</h1>
              <%= if @bundle.description not in [nil, ""] do %>
                <p class="mt-2 max-w-xl text-sm text-gray-500">{@bundle.description}</p>
              <% end %>
            </div>
            <div class="shrink-0 text-right">
              <p class="text-xs text-gray-400 mb-2">
                {length(@bundle.products)} items — select a variant per product below
              </p>
              <button
                phx-click="add_all_to_cart"
                class="rounded-full bg-[#C8001F] px-8 py-3 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
              >
                Add All to Cart — UGX {SheglowWeb.Format.price(@bundle_total)}
              </button>
            </div>
          </div>
        </div>
      </div>

      <%!-- Products --%>
      <div class="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <%= for product <- @bundle.products do %>
            <% sel = Map.get(@selected_variants, product.id, %{}) %>
            <% colors = colors_for(@variants_by_product, product.id) %>
            <% sizes = sizes_for(@variants_by_product, product.id, sel[:color_name]) %>

            <div class="rounded-2xl bg-white overflow-hidden shadow-sm">
              <%!-- Image --%>
              <a href={product.href} class="block overflow-hidden">
                <img
                  src={product.main_image}
                  alt={product.name}
                  class="aspect-square w-full object-cover object-top object-top transition-transform duration-300 hover:scale-105"
                />
              </a>

              <%!-- Badge --%>
              <%= if product.badge not in [nil, ""] do %>
                <span class="absolute mt-0 ml-3 -translate-y-full rounded-full bg-[#C8001F] px-2.5 py-1 text-[10px] font-semibold text-white">
                  {product.badge}
                </span>
              <% end %>

              <div class="p-4 space-y-3">
                <div>
                  <a href={product.href}>
                    <h3 class="text-sm font-semibold text-gray-900 leading-snug line-clamp-2">
                      {product.name}
                    </h3>
                  </a>
                  <p class="mt-1 text-sm font-bold text-gray-900">
                    UGX {SheglowWeb.Format.price(product.price)}
                  </p>
                </div>

                <%!-- Color selector --%>
                <%= if colors != [] do %>
                  <div>
                    <p class="mb-1.5 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
                      Formula: <span class="text-gray-600">{sel[:color_name]}</span>
                    </p>
                    <div class="flex flex-wrap gap-1.5">
                      <%= for c <- colors do %>
                        <button
                          type="button"
                          title={c.name}
                          phx-click="select_color"
                          phx-value-product_id={product.id}
                          phx-value-color={c.name}
                          phx-value-color_id={c.id}
                          phx-value-color_hex={c.hex}
                          class={[
                            "h-7 w-7 rounded-full border-2 transition",
                            if(sel[:color_name] == c.name,
                              do: "border-gray-900 ring-2 ring-gray-900 ring-offset-1",
                              else: "border-transparent hover:border-gray-400"
                            )
                          ]}
                          style={"background-color: #{c.hex}"}
                        />
                      <% end %>
                    </div>
                  </div>
                <% end %>

                <%!-- Size selector --%>
                <%= if sizes != [] do %>
                  <div>
                    <p class="mb-1.5 text-[10px] font-semibold uppercase tracking-wider text-gray-400">
                      Size / Volume: <span class="text-gray-600">{sel[:size]}</span>
                    </p>
                    <div class="flex flex-wrap gap-1.5">
                      <%= for s <- sizes do %>
                        <button
                          type="button"
                          phx-click="select_size"
                          phx-value-product_id={product.id}
                          phx-value-size={s}
                          class={[
                            "rounded-md border px-2.5 py-1 text-xs font-medium transition",
                            if(sel[:size] == s,
                              do: "border-gray-900 bg-gray-900 text-white",
                              else: "border-gray-200 text-gray-600 hover:border-gray-400"
                            )
                          ]}
                        >
                          {s}
                        </button>
                      <% end %>
                    </div>
                  </div>
                <% end %>

                <button
                  phx-click="add_to_cart"
                  phx-value-product_id={product.id}
                  class="w-full rounded-full border border-gray-300 py-2 text-xs font-semibold text-gray-700 transition hover:border-[#C8001F] hover:text-[#C8001F]"
                >
                  Add to Cart
                </button>
              </div>
            </div>
          <% end %>
        </div>

        <%!-- Bottom CTA --%>
        <div class="mt-12 rounded-2xl bg-white p-8 text-center shadow-sm">
          <p class="text-xs font-semibold uppercase tracking-widest text-[#C8001F]">
            Save More Together
          </p>
          <h2 class="mt-2 text-2xl font-bold text-gray-900">
            Get all {length(@bundle.products)} essentials in one go
          </h2>
          <p class="mt-2 text-sm text-gray-500">
            Variants selected above will be added to your cart.
          </p>
          <button
            phx-click="add_all_to_cart"
            class="mt-6 inline-block rounded-full bg-[#C8001F] px-10 py-3.5 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
          >
            Add All to Cart — UGX {SheglowWeb.Format.price(@bundle_total)}
          </button>
        </div>
      </div>

      <.footer />
    </div>
    """
  end

  defp bundle_navbar(assigns) do
    ~H"""
    <nav class="sticky top-0 z-30 border-b border-gray-100 bg-white/95 backdrop-blur">
      <div class="mx-auto flex max-w-7xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8">
        <a href="/" class="flex items-center gap-2">
          <img src="/images/sheglow-logo.png" alt="Sheglow" class="h-8 w-8 rounded-full object-cover" />
          <span class="brand-logo text-xl text-gray-900">
            SheGlow UG<span class="text-[#C8001F]">.</span>
          </span>
        </a>
        <a
          href="/cart"
          class="flex items-center gap-1.5 rounded-full border border-gray-200 px-4 py-2 text-sm font-medium text-gray-700 transition hover:border-gray-400"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
          Cart
        </a>
      </div>
    </nav>
    """
  end
end
