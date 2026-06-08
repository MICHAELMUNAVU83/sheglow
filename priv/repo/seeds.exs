alias Sheglow.Repo
alias Sheglow.Collections.Collection
alias Sheglow.Products.Product
alias Sheglow.ProductVariants.ProductVariant
alias Sheglow.Testimonials.Testimonial
alias Sheglow.InfoPages.InfoPage
alias Sheglow.Accounts
alias Sheglow.Accounts.User

default_shipping =
  "Kampala delivery available within 1-2 business days depending on location. Upcountry delivery takes 2-4 business days. Unopened products may be returned within 48 hours. WhatsApp +256 742 013968 for delivery support."

volume_options = ["30ml", "50ml", "100ml"]

cleanser_hero =
  "https://images.unsplash.com/photo-1686208561557-bb22083ec4df?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

cleanser_secondary =
  "https://images.unsplash.com/photo-1763622499218-37fdfc7a590a?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

toner_hero =
  "https://images.unsplash.com/photo-1738721797050-f4f1fb63acd7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

moisturizer_hero =
  "https://images.unsplash.com/photo-1705515626848-eac484a533e6?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

moisturizer_secondary =
  "https://images.unsplash.com/photo-1768235146417-4ccc5befad83?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

sunscreen_hero =
  "https://images.unsplash.com/photo-1623676714504-edd78728155e?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

sunscreen_secondary =
  "https://images.unsplash.com/photo-1744115617230-839654c3d5bd?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

sunscreen_studio =
  "https://images.unsplash.com/photo-1738721796968-bc0c4a55960d?fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

serum_hero =
  "https://images.unsplash.com/photo-1774999118349-43d391a89b7a?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

serum_secondary =
  "https://images.unsplash.com/photo-1741896135512-084b251887f7?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

serum_niacinamide =
  "https://images.unsplash.com/photo-1777450793530-99a0e7b7fc53?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

serum_clear =
  "https://images.unsplash.com/photo-1764694187721-a5035d777fdf?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=60&w=3000"

# Clear existing seed data so seeds can be re-run safely
Repo.delete_all(Sheglow.Testimonials.Testimonial)
Repo.delete_all(Sheglow.BundleItems.BundleItem)
Repo.delete_all(Sheglow.Bundles.Bundle)
Repo.delete_all(Sheglow.ProductVariants.ProductVariant)
Repo.delete_all(Sheglow.ProductImages.ProductImage)
Repo.delete_all(Sheglow.Products.Product)
Repo.delete_all(Sheglow.Collections.Collection)
IO.puts("Cleared existing seed data.")

# Collections
collections = [
  %{
    title: "Cleansers",
    slug: "cleansers",
    image: cleanser_hero,
    position: 1,
    is_active: true
  },
  %{
    title: "Toners",
    slug: "toners",
    image: toner_hero,
    position: 2,
    is_active: true
  },
  %{
    title: "Moisturizers",
    slug: "moisturizers",
    image: moisturizer_hero,
    position: 3,
    is_active: true
  },
  %{
    title: "Sun Protection",
    slug: "sun-protection",
    image: sunscreen_hero,
    position: 4,
    is_active: true
  },
  %{
    title: "Treatment Serums",
    slug: "treatment-serums",
    image: serum_hero,
    position: 5,
    is_active: true
  }
]

inserted_collections =
  Enum.map(collections, fn attrs ->
    {:ok, collection} =
      %Collection{}
      |> Collection.changeset(attrs)
      |> Repo.insert()

    collection
  end)

get_collection = fn slug ->
  Enum.find(inserted_collections, &(&1.slug == slug))
end

# Products
products = [
  %{
    name: "SheGlow Gentle Cleanser",
    slug: "sheglow-gentle-cleanser",
    description:
      "A creamy daily cleanser that lifts away dirt, sunscreen, and excess oil without leaving skin tight. Built for the first step of a calm, balanced glow routine.",
    base_price: 28_000,
    image: cleanser_hero,
    badge_label: "Bestseller",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: true,
    is_new_arrival: false,
    position: 1,
    status: "active",
    size_advice:
      "Best for normal, dry, and sensitive skin. Use morning and evening on damp skin, then rinse with lukewarm water.",
    shipping_returns: default_shipping,
    collection_slug: "cleansers",
    colors: [{"Sensitive Care", "#E9CBD4"}, {"Glow Reset", "#B65C78"}]
  },
  %{
    name: "Daily Clarifying Cleanser",
    slug: "daily-clarifying-cleanser",
    description:
      "A lightweight gel cleanser made to refresh oily and combination skin while helping reduce the look of congestion and shine.",
    base_price: 32_000,
    image: cleanser_secondary,
    badge_label: "New",
    badge_color: "green",
    is_featured: true,
    is_bestseller: false,
    is_new_arrival: true,
    position: 2,
    status: "active",
    size_advice:
      "Ideal for oily and combination skin. Massage into damp skin for 60 seconds, focusing on the T-zone before rinsing.",
    shipping_returns: default_shipping,
    collection_slug: "cleansers",
    colors: [{"Clear Balance", "#DDA39E"}, {"Tea Tree Fresh", "#8FAF7E"}]
  },
  %{
    name: "Cream Barrier Cleanser",
    slug: "cream-barrier-cleanser",
    description:
      "A nourishing cleanser that supports the skin barrier while gently removing buildup. Leaves skin soft, smooth, and ready for toner.",
    base_price: 34_000,
    image: cleanser_secondary,
    badge_label: nil,
    badge_color: nil,
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: false,
    position: 3,
    status: "active",
    size_advice:
      "Great for dry or stressed skin. Pair with a hydrating toner and moisturizer when your skin feels stripped or tired.",
    shipping_returns: default_shipping,
    collection_slug: "cleansers",
    colors: [{"Barrier Restore", "#F2D8DE"}, {"Comfort Clean", "#C9907E"}]
  },
  %{
    name: "Rose Balance Toner",
    slug: "rose-balance-toner",
    description:
      "A daily balancing toner infused with a soft floral feel that helps refresh the skin after cleansing and prep it for serum absorption.",
    base_price: 26_000,
    image: toner_hero,
    badge_label: "Featured",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: false,
    is_new_arrival: false,
    position: 4,
    status: "active",
    size_advice:
      "Works beautifully for normal and combination skin. Pat onto clean skin with hands or a cotton pad before serum.",
    shipping_returns: default_shipping,
    collection_slug: "toners",
    colors: [{"Rose Glow", "#D78A99"}, {"Hydra Calm", "#F4D9DE"}]
  },
  %{
    name: "Hydra Calm Toner",
    slug: "hydra-calm-toner",
    description:
      "A soothing hydrating toner that helps soften the look of dehydration and leaves skin feeling comforted and supple.",
    base_price: 29_000,
    image: toner_hero,
    badge_label: "New",
    badge_color: "green",
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: true,
    position: 5,
    status: "active",
    size_advice:
      "Best for dry or sensitive skin. Layer 1-2 passes after cleansing whenever your skin feels thirsty.",
    shipping_returns: default_shipping,
    collection_slug: "toners",
    colors: [{"Hydra Veil", "#E7C8D1"}, {"Soft Calm", "#C0D6D2"}]
  },
  %{
    name: "Pore Reset Toner",
    slug: "pore-reset-toner",
    description:
      "A refining toner that helps freshen pores, reduce excess oil feel, and leave the skin looking clearer and more balanced.",
    base_price: 31_000,
    image: serum_secondary,
    badge_label: nil,
    badge_color: nil,
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: false,
    position: 6,
    status: "active",
    size_advice:
      "Best for oily and breakout-prone skin. Use once or twice daily and always follow with moisturizer.",
    shipping_returns: default_shipping,
    collection_slug: "toners",
    colors: [{"Pore Care", "#8C5A6D"}, {"Fresh Reset", "#B8C9DC"}]
  },
  %{
    name: "Daily Dew Moisturizer",
    slug: "daily-dew-moisturizer",
    description:
      "A lightweight moisturizer that locks in hydration and gives skin a smooth, healthy-looking finish for all-day comfort.",
    base_price: 38_000,
    image: moisturizer_hero,
    badge_label: "Bestseller",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: true,
    is_new_arrival: false,
    position: 7,
    status: "active",
    size_advice:
      "Suitable for most skin types. Apply after toner or serum, morning and evening, for balanced hydration.",
    shipping_returns: default_shipping,
    collection_slug: "moisturizers",
    colors: [{"Daily Dew", "#EACFD6"}, {"Glow Finish", "#B65C78"}]
  },
  %{
    name: "Rich Repair Moisturizer",
    slug: "rich-repair-moisturizer",
    description:
      "A richer face cream made for skin that needs more comfort, helping support a soft, nourished, and resilient glow.",
    base_price: 44_000,
    image: moisturizer_secondary,
    badge_label: "Featured",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: false,
    is_new_arrival: false,
    position: 8,
    status: "active",
    size_advice:
      "Perfect for dry skin and night routines. Apply as the last step after toner and serum to seal in moisture.",
    shipping_returns: default_shipping,
    collection_slug: "moisturizers",
    colors: [{"Repair Cream", "#C98997"}, {"Deep Comfort", "#7B3F57"}]
  },
  %{
    name: "Oil Control Gel Cream",
    slug: "oil-control-gel-cream",
    description:
      "A breathable gel-cream that hydrates without heaviness and helps keep the skin feeling fresh through the day.",
    base_price: 36_000,
    image: moisturizer_secondary,
    badge_label: "New",
    badge_color: "green",
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: true,
    position: 9,
    status: "active",
    size_advice:
      "Great for oily, acne-prone, and combination skin. Use a pea-sized amount after toner or serum.",
    shipping_returns: default_shipping,
    collection_slug: "moisturizers",
    colors: [{"Oil Balance", "#B7C7C4"}, {"Light Glow", "#E9D2D8"}]
  },
  %{
    name: "Glow Shield Sunscreen SPF 50+",
    slug: "glow-shield-sunscreen-spf-50",
    description:
      "A broad-spectrum daily sunscreen that helps protect your glow with a smooth finish that layers well under makeup.",
    base_price: 42_000,
    image: sunscreen_studio,
    badge_label: "Bestseller",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: true,
    is_new_arrival: false,
    position: 10,
    status: "active",
    size_advice:
      "Use every morning as the final skincare step. Reapply during the day when outdoors or after sweating.",
    shipping_returns: default_shipping,
    collection_slug: "sun-protection",
    colors: [{"Glow Shield", "#F2E3D5"}, {"Invisible Guard", "#D8C0A8"}]
  },
  %{
    name: "Matte Guard Sunscreen SPF 50+",
    slug: "matte-guard-sunscreen-spf-50",
    description:
      "A shine-controlled sunscreen designed for oily and combination skin, helping protect without a greasy after-feel.",
    base_price: 40_000,
    image: sunscreen_hero,
    badge_label: nil,
    badge_color: nil,
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: false,
    position: 11,
    status: "active",
    size_advice:
      "Best for oily or humid-day wear. Apply generously 15 minutes before sun exposure.",
    shipping_returns: default_shipping,
    collection_slug: "sun-protection",
    colors: [{"Matte Guard", "#D2B7A0"}, {"Oil Control", "#8F6B60"}]
  },
  %{
    name: "Body Veil Sunscreen SPF 30",
    slug: "body-veil-sunscreen-spf-30",
    description:
      "A lightweight body sunscreen for everyday wear that helps keep arms, shoulders, and exposed skin comfortably protected.",
    base_price: 35_000,
    image: sunscreen_secondary,
    badge_label: "New",
    badge_color: "green",
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: true,
    position: 12,
    status: "active",
    size_advice:
      "Apply generously to exposed body areas and reapply after swimming, sweating, or towel drying.",
    shipping_returns: default_shipping,
    collection_slug: "sun-protection",
    colors: [{"Body Veil", "#E8D7CC"}, {"Sun Comfort", "#C7A68D"}]
  },
  %{
    name: "Vitamin C Glow Serum",
    slug: "vitamin-c-glow-serum",
    description:
      "A brightening serum that helps revive dull-looking skin and support a more radiant, even-looking complexion.",
    base_price: 48_000,
    image: serum_hero,
    badge_label: "Featured",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: false,
    is_new_arrival: true,
    position: 13,
    status: "active",
    size_advice:
      "Best for dull or uneven-looking skin. Apply 2-3 drops after toner in the morning, then follow with sunscreen.",
    shipping_returns: default_shipping,
    collection_slug: "treatment-serums",
    colors: [{"Radiance Boost", "#D88F6B"}, {"Glow Target", "#B65C78"}]
  },
  %{
    name: "Niacinamide Balance Serum",
    slug: "niacinamide-balance-serum",
    description:
      "A balancing serum that helps refine the appearance of pores, calm visible oiliness, and leave skin feeling smoother.",
    base_price: 46_000,
    image: serum_niacinamide,
    badge_label: nil,
    badge_color: nil,
    is_featured: false,
    is_bestseller: false,
    is_new_arrival: false,
    position: 14,
    status: "active",
    size_advice:
      "A great pick for oily and combination skin. Use morning or night before moisturizer.",
    shipping_returns: default_shipping,
    collection_slug: "treatment-serums",
    colors: [{"Balance Boost", "#B8C9DC"}, {"Clear Comfort", "#8C5A6D"}]
  },
  %{
    name: "Hyaluronic Bounce Serum",
    slug: "hyaluronic-bounce-serum",
    description:
      "A hydration-first serum that helps skin feel plumper, softer, and visibly refreshed throughout the day.",
    base_price: 45_000,
    image: serum_clear,
    badge_label: "Bestseller",
    badge_color: "rose",
    is_featured: true,
    is_bestseller: true,
    is_new_arrival: false,
    position: 15,
    status: "active",
    size_advice:
      "Perfect for dry, dehydrated, or tired-looking skin. Apply to slightly damp skin before moisturizer.",
    shipping_returns: default_shipping,
    collection_slug: "treatment-serums",
    colors: [{"Hydra Bounce", "#D7E6EA"}, {"Soft Plump", "#EBCED4"}]
  }
]

inserted_products =
  Enum.map(products, fn attrs ->
    {collection_slug, attrs} = Map.pop(attrs, :collection_slug)
    {colors, attrs} = Map.pop(attrs, :colors)
    collection = get_collection.(collection_slug)
    attrs = Map.put(attrs, :collection_id, collection.id)

    {:ok, product} =
      %Product{}
      |> Product.changeset(attrs)
      |> Repo.insert()

    Enum.each(colors, fn {color_name, color_hex} ->
      Enum.each(volume_options, fn volume ->
        {:ok, _variant} =
          %ProductVariant{}
          |> ProductVariant.changeset(%{
            product_id: product.id,
            color_name: color_name,
            color_hex: color_hex,
            size: volume,
            stock_quantity: "12"
          })
          |> Repo.insert()
      end)
    end)

    product
  end)

get_product = fn slug ->
  Enum.find(inserted_products, &(&1.slug == slug))
end

variant_count = length(inserted_products) * length(volume_options) * 2

IO.puts(
  "Seeded #{length(inserted_collections)} collections, #{length(inserted_products)} products, and about #{variant_count} variants."
)

# Bundle
{:ok, bundle} =
  %Sheglow.Bundles.Bundle{}
  |> Sheglow.Bundles.Bundle.changeset(%{
    title: "The SheGlow Everyday Routine",
    description:
      "A complete starter routine with a cleanser, toner, moisturizer, and sunscreen to help you nourish, protect, and maintain your glow every day.",
    image: cleanser_hero,
    is_active: true
  })
  |> Repo.insert()

bundle_item_slugs = [
  "sheglow-gentle-cleanser",
  "rose-balance-toner",
  "daily-dew-moisturizer",
  "glow-shield-sunscreen-spf-50"
]

Enum.each(bundle_item_slugs, fn slug ->
  product = get_product.(slug)

  {:ok, _bundle_item} =
    %Sheglow.BundleItems.BundleItem{}
    |> Sheglow.BundleItems.BundleItem.changeset(%{
      bundle_id: bundle.id,
      product_id: product.id
    })
    |> Repo.insert()
end)

IO.puts("Seeded 1 active bundle.")

# Testimonials
testimonials = [
  %{
    name: "Amina W.",
    position: 1,
    image: "/images/people/woman1.jpg",
    body:
      "The Gentle Cleanser and Daily Dew Moisturizer made my routine feel so simple. My skin feels softer and looks healthier even on makeup-free days.",
    rating: 5,
    is_active: true,
    product_slug: "sheglow-gentle-cleanser"
  },
  %{
    name: "Cynthia O.",
    position: 2,
    image: "/images/people/woman2.jpg",
    body:
      "I started using the Rose Balance Toner and Vitamin C Glow Serum together and my skin has looked brighter and more even after just a couple of weeks.",
    rating: 5,
    is_active: true,
    product_slug: "rose-balance-toner"
  },
  %{
    name: "Grace M.",
    position: 3,
    image: "/images/people/woman3.jpg",
    body:
      "Glow Shield Sunscreen sits so well under makeup and does not leave me looking ashy. It has become the one product I never skip.",
    rating: 5,
    is_active: true,
    product_slug: "glow-shield-sunscreen-spf-50"
  },
  %{
    name: "Fatuma K.",
    position: 4,
    image: "/images/people/woman4.jpg",
    body:
      "The Hyaluronic Bounce Serum gives my skin that fresh, bouncy feel by morning. The packaging and service also feel really thoughtful.",
    rating: 5,
    is_active: true,
    product_slug: "hyaluronic-bounce-serum"
  }
]

Enum.each(testimonials, fn attrs ->
  {product_slug, attrs} = Map.pop(attrs, :product_slug)
  product = get_product.(product_slug)

  {:ok, _testimonial} =
    %Testimonial{}
    |> Testimonial.changeset(Map.put(attrs, :product_id, product.id))
    |> Repo.insert()
end)

IO.puts("Seeded #{length(testimonials)} testimonials.")

# Info pages are not cleared on re-seed so admin edits are preserved.
info_pages = [
  %{
    slug: "how-to-order",
    title: "How to Order",
    icon: "🛍️",
    position: 1,
    meta_description:
      "How to place your skincare order with SheGlow UG through WhatsApp or the website.",
    content: """
    ## How to Place Your Order

    Ordering from SheGlow UG is simple:

    ### Option 1 - WhatsApp Us

    - Send us the products you want or tell us your skin goal.
    - Share your name, phone number, and delivery location.
    - We will confirm availability, recommend a routine if needed, and share your total.
    - Complete payment using the payment option shared by our team.
    - We dispatch once payment is confirmed.

    ### Option 2 - Order Through the Website

    - Add your skincare essentials to cart.
    - Enter your delivery details at checkout.
    - Submit your order and wait for confirmation from our team.

    ### Need Help Choosing?

    Reach us on **WhatsApp: +256 742 013968** and we will help you build the right routine.
    """
  },
  %{
    slug: "size-guide",
    title: "Skin Guide",
    icon: "✨",
    position: 2,
    meta_description:
      "A simple SheGlow UG skin guide for dry, oily, combination, and sensitive skin.",
    content: """
    ## Know Your Skin

    Understanding your skin helps you choose the right products and build a routine that works.

    ### Dry Skin

    - Often feels tight after cleansing
    - Can look dull or flaky
    - Benefits from hydrating toners, richer moisturizers, and barrier-support products

    ### Oily Skin

    - Produces excess shine, especially through the T-zone
    - May experience visible congestion or enlarged pores
    - Benefits from balancing cleansers, lightweight moisturizers, and daily sunscreen

    ### Combination Skin

    - Oily in some areas and dry in others
    - Needs a balanced routine that hydrates without feeling heavy

    ### Sensitive Skin

    - Can react easily to new products or harsh formulas
    - Benefits from gentle cleansing, calming hydration, and barrier-friendly care

    ### A Simple Starter Routine

    1. Cleanser
    2. Toner
    3. Serum
    4. Moisturizer
    5. Sunscreen in the daytime
    """
  },
  %{
    slug: "shipping-delivery",
    title: "Shipping & Delivery",
    icon: "🚚",
    position: 3,
    meta_description:
      "SheGlow UG shipping and delivery information for Kampala and upcountry orders.",
    content: """
    ## Shipping & Delivery

    We deliver across Uganda.

    ### Kampala

    - Standard delivery: 1-2 business days
    - Delivery fee depends on your location and is confirmed before dispatch

    ### Upcountry

    - Delivery usually takes 2-4 business days
    - Final shipping fee depends on destination and courier method

    ### Important Notes

    - Orders are packed after confirmation from our team
    - Delivery timelines may shift on weekends or public holidays
    - Please ensure your phone number and delivery address are correct

    For delivery support, message **+256 742 013968**.
    """
  },
  %{
    slug: "returns-exchanges",
    title: "Returns & Exchanges",
    icon: "🔄",
    position: 4,
    meta_description: "SheGlow UG returns and exchanges policy for unopened skincare products.",
    content: """
    ## Returns & Exchanges

    We want you to shop with confidence.

    ### Eligible Returns

    - Wrong item received
    - Damaged product received
    - Unopened product reported within 48 hours of delivery

    ### Conditions

    - Products must be sealed and unused
    - Returns should be reported with clear photos and order details
    - Opened skincare products are not eligible for return unless they arrived damaged

    ### How to Request Help

    - Contact us on **WhatsApp: +256 742 013968**
    - Share your name, order details, and photos
    - Our team will guide you on the next step
    """
  }
]

inserted_info_pages =
  Enum.reduce(info_pages, 0, fn attrs, count ->
    case Repo.get_by(InfoPage, slug: attrs.slug) do
      nil ->
        {:ok, _page} =
          %InfoPage{}
          |> InfoPage.changeset(attrs)
          |> Repo.insert()

        count + 1

      _existing ->
        count
    end
  end)

IO.puts("Seeded #{inserted_info_pages} new info pages.")

# Admin users
admin_users = [
  %{
    name: "Admin",
    email: "admin@gmail.com",
    password: "123456",
    role: "super_admin"
  }
]

inserted_admins =
  Enum.reduce(admin_users, 0, fn attrs, count ->
    case Repo.get_by(User, email: attrs.email) do
      nil ->
        case Accounts.invite_user(attrs) do
          {:ok, _user} ->
            IO.puts("Created admin: #{attrs.email}")
            count + 1

          {:error, changeset} ->
            IO.puts("Failed to create #{attrs.email}: #{inspect(changeset.errors)}")
            count
        end

      existing ->
        {:ok, _user} = Accounts.admin_update_user(existing, Map.take(attrs, [:name, :role]))
        IO.puts("Admin already exists, updated role: #{attrs.email}")
        count
    end
  end)

IO.puts("Admin seed complete - #{inserted_admins} new admin user(s) created.")
