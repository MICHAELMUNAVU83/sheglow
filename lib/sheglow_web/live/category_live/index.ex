defmodule SheglowWeb.CategoryLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.Shop

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    category = Shop.get_collection_by_slug(slug)

    if is_nil(category) do
      {:ok,
       socket
       |> put_flash(:error, "Category not found")
       |> push_navigate(to: "/")}
    else
      product_types = Shop.list_collections_for_display()
      products = Shop.list_products_for_collection_display(category.id)
      popular = Shop.list_popular_products_for_display(3)
      hero_images = Shop.list_hero_images(6)

      {:ok,
       socket
       |> assign(:page_title, "#{category.name} | Sheglow")
       |> assign(:category, category)
       |> assign(:product_types, product_types)
       |> assign(:selected_types, [slug])
       |> assign(:bestsellers, Shop.list_bestsellers())
       |> assign(:filter_pill, "all")
       |> assign(:sort, "best_selling")
       |> assign(:products, products)
       |> assign(:popular_products, popular)
       |> assign(:contact_images, Enum.shuffle(hero_images))
       |> assign(:filters_open, false)}
    end
  end

  @impl true
  def handle_event("toggle_product_type", %{"slug" => slug}, socket) do
    current = socket.assigns.selected_types
    next    = if slug in current, do: List.delete(current, slug), else: [slug | current]

    {:noreply,
     socket
     |> assign(:selected_types, next)
     |> reload_products(next, socket.assigns.filter_pill, socket.assigns.sort)}
  end

  @impl true
  def handle_event("set_filter_pill", %{"pill" => pill}, socket) do
    {:noreply,
     socket
     |> assign(:filter_pill, pill)
     |> reload_products(socket.assigns.selected_types, pill, socket.assigns.sort)}
  end

  @impl true
  def handle_event("set_sort", %{"sort" => sort}, socket) do
    {:noreply,
     socket
     |> assign(:sort, sort)
     |> reload_products(socket.assigns.selected_types, socket.assigns.filter_pill, sort)}
  end

  defp reload_products(socket, slugs, pill, sort) do
    products = Shop.list_products_for_category_filter(slugs, pill, sort)
    assign(socket, :products, products)
  end

  @impl true
  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, :filters_open, !socket.assigns.filters_open)}
  end

  @impl true
  def handle_event("close_filters", _params, socket) do
    {:noreply, assign(socket, :filters_open, false)}
  end

  @impl true
  def handle_event("contact_submit", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Thanks! We'll get back to you soon.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="category-page" class="page-typography min-h-screen bg-white" phx-hook="HomeReveal">
      <.promo_bar />
      <.navbar collections={@product_types} />
      <.category_hero category={@category} />
      <.category_main
        product_types={@product_types}
        selected_types={@selected_types}
        filter_pill={@filter_pill}
        sort={@sort}
        products={@products}
        popular_products={@popular_products}
        filters_open={@filters_open}
      />
      <.features />
      <.countdown />
      <.best_sellers bestsellers={@bestsellers} />
      <.contact_section contact_images={@contact_images} />
      <.footer />
    </div>
    """
  end
end
