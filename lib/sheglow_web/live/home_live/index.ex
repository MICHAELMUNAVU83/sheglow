defmodule SheglowWeb.HomeLive.Index do
  use SheglowWeb, :live_view

  alias Sheglow.Shop
  alias Sheglow.Shop.DummyData

  @impl true
  def mount(_params, _session, socket) do
    collections = Shop.list_collections_for_display()
    hero_images = Shop.list_hero_images(6)

    {:ok,
     socket
     |> assign(:page_title, "Healthy Skin, Confident You")
     |> assign(:collections, collections)
     |> assign(:featured_collections, Enum.take(collections, 2))
     |> assign(:hero_images, hero_images)
     |> assign(:contact_images, Enum.shuffle(hero_images))
     |> assign(:products, Shop.list_new_arrivals())
     |> assign(:bestsellers, Shop.list_bestsellers())
     |> assign(:active_bundle, Shop.get_active_bundle_with_products())
     |> assign(:testimonials, Shop.list_testimonials_for_display())
     |> assign(:instagram_images, DummyData.instagram_images())
     |> assign(:sale_banner, Shop.get_sale_banner_data())
     |> assign(:sale_banner_index, 0)
     |> assign(:marquee_items, DummyData.marquee_items())
     |> assign(:countdown_collection, Enum.random(collections))
     |> assign(:hero_collection, Enum.random(collections))}
  end

  @impl true
  def handle_event("contact_submit", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Thanks! We'll get back to you soon.")}
  end

  @impl true
  def handle_event("select_sale_slide", %{"index" => raw_index}, socket) do
    index = String.to_integer(raw_index)
    slides = socket.assigns.sale_banner.slides
    max_index = length(slides) - 1
    index = min(max(0, index), max_index)
    {:noreply, assign(socket, :sale_banner_index, index)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="home-page" class="page-typography" phx-hook="HomeReveal">
      <.promo_bar />
      <.navbar collections={@collections} />
      <.hero hero_images={@hero_images} collections={@collections} hero_collection={@hero_collection} />
      <.collections collections={@collections} />
      <.sale_banner sale_banner={@sale_banner} current_index={@sale_banner_index} />
      <.new_arrivals products={@products} />
      <.banner items={@marquee_items} />
      <.two_column_collection featured_collections={@featured_collections} />
      <.video_banner />
      <.bundle_and_save active_bundle={@active_bundle} />
      <.testimonials testimonials={@testimonials} />
      <.best_sellers bestsellers={@bestsellers} />
      <.countdown collection={@countdown_collection} />
      <.features />
      <.contact_section contact_images={@contact_images} />
      <.footer />
    </div>
    """
  end
end
