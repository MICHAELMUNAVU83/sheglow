defmodule Sheglow.Shop.DummyData do
  @moduledoc """
  Dummy data for development and testing.
  Use in LiveView: assign(socket, YourApp.Shop.DummyData.all())
  """

  def all do
    %{
      collections: collections(),
      products: products(),
      new_arrivals: new_arrivals(),
      bestsellers: bestsellers(),
      bundle_products: bundle_products(),
      testimonials: testimonials(),
      partners: partners(),
      instagram_images: instagram_images(),
      hero: hero(),
      sale_banner: sale_banner(),
      countdown: countdown()
    }
  end

  # =============================================================================
  # HERO SECTION
  # =============================================================================
  def hero do
    %{
      season: "SPRING 2025",
      title: "Quiet Luxury!\nTimeless Form.",
      description:
        "Discover our latest collection where fluid design meets architectural precision. Each piece is crafted to move with you.",
      stats: [
        %{value: "40", label: "New Pieces"},
        %{value: "100%", label: "Sustainable"}
      ],
      image: "/images/main.jpeg",
      cta_primary: %{text: "Shop Now", href: "/shop"},
      cta_secondary: %{text: "View More", href: "/collections"}
    }
  end

  # =============================================================================
  # SALE BANNER
  # =============================================================================
  def sale_banner do
    %{
      label: "BIGGEST SALE OFFER",
      title: "New & Modern Products\nin Our Online Store",
      discount_text: "Midseason Sale",
      discount_percent: "25% Off!",
      note: "Only Selected Product",
      featured_product: %{
        id: "prod_featured_1",
        name: "Light Wash Oversized Denim Jacket",
        price: Decimal.new("128.00"),
        original_price: Decimal.new("138.00"),
        badge: "7%",
        image: "/images/main.jpeg",
        colors: [
          %{name: "Navy", hex: "#1e3a5f", selected: true},
          %{name: "Light Blue", hex: "#b8c9dc", selected: false},
          %{name: "Charcoal", hex: "#4a4a4a", selected: false}
        ]
      },
      background_image: "/images/main.jpeg",
      # Slides for the banner carousel (big image changes when dots are clicked)
      slides: [
        %{image: "/images/main.jpeg", alt: "SheGlow skincare"},
        %{image: "/images/main.jpeg", alt: "Spring collection"},
        %{image: "/images/main.jpeg", alt: "Modern dress"},
        %{image: "/images/main.jpeg", alt: "Denim jacket"},
        %{image: "/images/main.jpeg", alt: "Midi dress"}
      ]
    }
  end

  # =============================================================================
  # COUNTDOWN
  # =============================================================================
  def countdown do
    # Set end date 9 days from now
    end_date = DateTime.utc_now() |> DateTime.add(9 * 24 * 60 * 60, :second)

    %{
      label: "UP TO 25% OFF SALE",
      title: "Get Your Dress Look Today",
      description: "We checked out a bunch of stores and finally found the perfect dress!",
      end_date: end_date,
      cta: %{text: "Shop The Sale", href: "/sale"}
    }
  end

  # =============================================================================
  # COLLECTIONS
  # =============================================================================
  def collections do
    [
      %{
        id: "col_1",
        name: "Tops",
        slug: "tops",
        description: "Casual and formal tops for every occasion",
        item_count: 3,
        image: "/images/main.jpeg",
        is_active: false,
        href: "/collections/tops"
      },
      %{
        id: "col_2",
        name: "Dresses",
        slug: "dresses",
        description: "Elegant dresses for every style",
        item_count: 4,
        image: "/images/main.jpeg",
        is_active: false,
        href: "/collections/dresses"
      },
      %{
        id: "col_3",
        name: "Jackets",
        slug: "jackets",
        description: "Stylish outerwear for all seasons",
        item_count: 5,
        image: "/images/main.jpeg",
        is_active: false,
        href: "/collections/jackets"
      },
      %{
        id: "col_4",
        name: "Skirts",
        slug: "skirts",
        description: "Trendy skirts in various lengths",
        item_count: 2,
        image: "/images/main.jpeg",
        is_active: true,
        href: "/collections/skirts"
      },
      %{
        id: "col_5",
        name: "Casual",
        slug: "casual",
        description: "Everyday comfort wear",
        item_count: 9,
        image: "/images/main.jpeg",
        is_active: false,
        href: "/collections/casual"
      }
    ]
  end

  def category_by_slug(slug) do
    collections()
    |> Enum.find(fn c -> c.slug == slug end)
    |> case do
      nil ->
        nil

      c ->
        %{
          id: c.id,
          name: c.name,
          slug: c.slug,
          title: "Our Product Collection",
          subtitle: "EXPLORE OUR PRODUCT",
          hero_image: c.image,
          href: c.href
        }
    end
  end

  def popular_products do
    [
      %{
        id: "pop_1",
        name: "Modern Shirt and Jean Outfit",
        price: Decimal.new("276.00"),
        currency: "USD",
        image: "/images/main.jpeg",
        rating: 4.0,
        href: "#"
      },
      %{
        id: "pop_2",
        name: "Cropped Stonewash Denim Jacket",
        price: Decimal.new("135.00"),
        currency: "USD",
        image: "/images/main.jpeg",
        rating: 4.0,
        href: "#"
      },
      %{
        id: "pop_3",
        name: "Fitted Classic Blue Denim Jacket",
        price: Decimal.new("132.00"),
        currency: "USD",
        image: "/images/main.jpeg",
        rating: 4.5,
        href: "#"
      }
    ]
  end

  def products_for_category(slug) do
    coll = collections() |> Enum.find(fn c -> c.slug == slug end)

    list =
      if coll do
        products() |> Enum.filter(fn p -> p.collection_id == coll.id end)
      else
        products()
      end

    # Ensure at least 6 for grid; pad with more products if needed
    if length(list) >= 6, do: list, else: list ++ Enum.take(products(), max(0, 6 - length(list)))
  end

  def featured_collections do
    [
      %{
        id: "feat_col_1",
        label: "NEW COLLECTION",
        title: "ElegantDesign\nDress",
        image: "/images/main.jpeg",
        href: "/collections/elegant"
      },
      %{
        id: "feat_col_2",
        label: "UP TO 30% OFF",
        title: "ModernDesign\nDress",
        image: "/images/main.jpeg",
        href: "/collections/modern"
      }
    ]
  end

  # =============================================================================
  # PRODUCTS
  # =============================================================================
  def products do
    [
      %{
        id: "prod_1",
        name: "Fitted Classic Blue Denim Jacket",
        slug: "fitted-classic-blue-denim-jacket",
        description: "A timeless denim jacket with a modern fit.",
        price: Decimal.new("132.00"),
        original_price: nil,
        currency: "USD",
        badge: nil,
        rating: Decimal.new("4.5"),
        reviews_count: 24,
        main_image: "/images/main.jpeg",
        gallery_images: [
          "/images/main.jpeg",
          "/images/main.jpeg",
          "/images/main.jpeg"
        ],
        colors: [
          %{id: "c1", name: "Navy", hex: "#1e3a5f", selected: true},
          %{id: "c2", name: "Light Blue", hex: "#b8c9dc", selected: false},
          %{id: "c3", name: "Charcoal", hex: "#4a4a4a", selected: false}
        ],
        sizes: [
          %{id: "s1", name: "XS", available: true},
          %{id: "s2", name: "S", available: true},
          %{id: "s3", name: "M", available: true},
          %{id: "s4", name: "L", available: false},
          %{id: "s5", name: "XL", available: true}
        ],
        collection_id: "col_3",
        is_featured: true,
        is_active: true,
        stock_quantity: 15,
        sku: "DJK-1203"
      },
      %{
        id: "prod_2",
        name: "Cropped Stonewash Denim Jacket",
        slug: "cropped-stonewash-denim-jacket",
        description: "Modern cropped jacket with stonewash finish.",
        price: Decimal.new("135.00"),
        original_price: Decimal.new("145.00"),
        currency: "USD",
        badge: "7%",
        rating: Decimal.new("4.8"),
        reviews_count: 36,
        main_image: "/images/main.jpeg",
        gallery_images: [
          "/images/main.jpeg",
          "/images/main.jpeg"
        ],
        colors: [
          %{id: "c1", name: "Beige", hex: "#c9b896", selected: false},
          %{id: "c2", name: "Navy", hex: "#1e3a5f", selected: true},
          %{id: "c3", name: "Light Blue", hex: "#b8c9dc", selected: false}
        ],
        sizes: [
          %{id: "s1", name: "XS", available: true},
          %{id: "s2", name: "S", available: true},
          %{id: "s3", name: "M", available: true},
          %{id: "s4", name: "L", available: true},
          %{id: "s5", name: "XL", available: false}
        ],
        collection_id: "col_3",
        is_featured: true,
        is_active: true,
        stock_quantity: 8,
        sku: "DJK-1204"
      },
      %{
        id: "prod_3",
        name: "Shadow Bloom Crinkle Midi",
        slug: "shadow-bloom-crinkle-midi",
        description: "Elegant midi dress with crinkle texture.",
        price: Decimal.new("315.00"),
        original_price: nil,
        currency: "USD",
        badge: nil,
        rating: Decimal.new("4.7"),
        reviews_count: 18,
        main_image: "/images/main.jpeg",
        gallery_images: [
          "/images/main.jpeg"
        ],
        colors: [
          %{id: "c1", name: "Burgundy", hex: "#722f37", selected: true},
          %{id: "c2", name: "Dusty Rose", hex: "#b5a1a1", selected: false},
          %{id: "c3", name: "Sky Blue", hex: "#a4c2d8", selected: false}
        ],
        sizes: [
          %{id: "s1", name: "XS", available: true},
          %{id: "s2", name: "S", available: true},
          %{id: "s3", name: "M", available: false},
          %{id: "s4", name: "L", available: true}
        ],
        collection_id: "col_2",
        is_featured: true,
        is_active: true,
        stock_quantity: 5,
        sku: "DJK-1205"
      },
      %{
        id: "prod_4",
        name: "Ribbed Halter-Neck Cutout Top",
        slug: "ribbed-halter-neck-cutout-top",
        description: "Trendy halter top with unique cutout design.",
        price: Decimal.new("228.00"),
        original_price: nil,
        currency: "USD",
        badge: "Sale",
        rating: Decimal.new("4.3"),
        reviews_count: 42,
        main_image: "/images/main.jpeg",
        gallery_images: [
          "/images/main.jpeg",
          "/images/main.jpeg"
        ],
        colors: [
          %{id: "c1", name: "Sage", hex: "#9caf88", selected: true},
          %{id: "c2", name: "Dusty Purple", hex: "#a5969c", selected: false},
          %{id: "c3", name: "Navy", hex: "#1e3a5f", selected: false}
        ],
        sizes: [
          %{id: "s1", name: "XS", available: true},
          %{id: "s2", name: "S", available: true},
          %{id: "s3", name: "M", available: true},
          %{id: "s4", name: "L", available: true}
        ],
        collection_id: "col_1",
        is_featured: true,
        is_active: true,
        stock_quantity: 20,
        sku: "DJK-1206"
      },
      %{
        id: "prod_5",
        name: "Ribbed Halter-Neck Cutout Top",
        slug: "ribbed-halter-neck-cutout-top-test",
        description: "Trendy halter top with unique cutout design.",
        price: Decimal.new("228.00"),
        original_price: nil,
        currency: "USD",
        badge: "Sale",
        rating: Decimal.new("4.3"),
        reviews_count: 42,
        main_image: "/images/main.jpeg",
        gallery_images: [
          "/images/main.jpeg",
          "/images/main.jpeg"
        ],
        colors: [
          %{id: "c1", name: "Sage", hex: "#9caf88", selected: true},
          %{id: "c2", name: "Dusty Purple", hex: "#a5969c", selected: false},
          %{id: "c3", name: "Navy", hex: "#1e3a5f", selected: false}
        ],
        sizes: [
          %{id: "s1", name: "XS", available: true},
          %{id: "s2", name: "S", available: true},
          %{id: "s3", name: "M", available: true},
          %{id: "s4", name: "L", available: true}
        ],
        collection_id: "col_1",
        is_featured: true,
        is_active: true,
        stock_quantity: 20,
        sku: "DJK-1206"
      }
    ]
  end

  def product_by_slug(slug) do
    product = products() |> Enum.find(fn p -> p.slug == slug end)

    if product do
      sku = Map.get(product, :sku, "DJK-#{String.replace(product.id, "prod_", "")}")
      collection = collections() |> Enum.find(fn c -> c.id == product.collection_id end)
      product_type = if collection, do: collection.name, else: "Product"

      product
      |> Map.put(:sku, sku)
      |> Map.put(:product_type, product_type)
    end
  end

  def related_products(current_product_id, limit \\ 4) do
    products()
    |> Enum.reject(fn p -> p.id == current_product_id end)
    |> Enum.take(limit)
  end

  def new_arrivals do
    [
      %{
        id: "new_1",
        name: "Fitted Classic Blue Denim Jacket",
        slug: "fitted-classic-blue-denim-jacket",
        price: Decimal.new("132.00"),
        original_price: nil,
        currency: "USD",
        badge: nil,
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Navy", hex: "#1e3a5f", selected: true},
          %{id: "c2", name: "Light Blue", hex: "#b8c9dc", selected: false},
          %{id: "c3", name: "Charcoal", hex: "#4a4a4a", selected: false}
        ],
        href: "/products/fitted-classic-blue-denim-jacket"
      },
      %{
        id: "new_2",
        name: "Cropped Stonewash Denim Jacket",
        slug: "cropped-stonewash-denim-jacket",
        price: Decimal.new("135.00"),
        original_price: Decimal.new("145.00"),
        currency: "USD",
        badge: "7%",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Beige", hex: "#c9b896", selected: false},
          %{id: "c2", name: "Navy", hex: "#1e3a5f", selected: true},
          %{id: "c3", name: "Light Blue", hex: "#b8c9dc", selected: false}
        ],
        href: "/products/cropped-stonewash-denim-jacket"
      },
      %{
        id: "new_3",
        name: "Shadow Bloom Crinkle Midi",
        slug: "shadow-bloom-crinkle-midi",
        price: Decimal.new("315.00"),
        original_price: nil,
        currency: "USD",
        badge: nil,
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Burgundy", hex: "#722f37", selected: true},
          %{id: "c2", name: "Dusty Rose", hex: "#b5a1a1", selected: false},
          %{id: "c3", name: "Sky Blue", hex: "#a4c2d8", selected: false}
        ],
        href: "/products/shadow-bloom-crinkle-midi"
      },
      %{
        id: "new_4",
        name: "Ribbed Halter-Neck Cutout Top",
        slug: "ribbed-halter-neck-cutout-top",
        price: Decimal.new("228.00"),
        original_price: nil,
        currency: "USD",
        badge: "Sale",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Sage", hex: "#9caf88", selected: true},
          %{id: "c2", name: "Dusty Purple", hex: "#a5969c", selected: false},
          %{id: "c3", name: "Navy", hex: "#1e3a5f", selected: false}
        ],
        href: "/products/ribbed-halter-neck-cutout-top"
      },
      %{
        id: "new_5",
        name: "Ribbed Halter-Neck Cutout Top",
        slug: "ribbed-halter-neck-cutout-top",
        price: Decimal.new("228.00"),
        original_price: nil,
        currency: "USD",
        badge: "Sale",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Sage", hex: "#9caf88", selected: true},
          %{id: "c2", name: "Dusty Purple", hex: "#a5969c", selected: false},
          %{id: "c3", name: "Navy", hex: "#1e3a5f", selected: false}
        ],
        href: "/products/ribbed-halter-neck-cutout-top"
      }
    ]
  end

  def bestsellers do
    [
      %{
        id: "best_1",
        name: "Rust Red Gold Satin Dress",
        slug: "rust-red-gold-satin-dress",
        price: Decimal.new("179.00"),
        original_price: nil,
        currency: "USD",
        rating: Decimal.new("4.5"),
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Red", hex: "#c41e3a", selected: true},
          %{id: "c2", name: "Olive", hex: "#6b8e23", selected: false},
          %{id: "c3", name: "Gold", hex: "#daa520", selected: false}
        ],
        href: "/products/rust-red-gold-satin-dress"
      },
      %{
        id: "best_2",
        name: "Classic Shirt & Denim Outfit",
        slug: "classic-shirt-denim-outfit",
        price: Decimal.new("159.00"),
        original_price: nil,
        currency: "USD",
        rating: Decimal.new("4.5"),
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "White", hex: "#ffffff", selected: true},
          %{id: "c2", name: "Dusty Purple", hex: "#a5969c", selected: false},
          %{id: "c3", name: "Light Blue", hex: "#b8c9dc", selected: false}
        ],
        href: "/products/classic-shirt-denim-outfit"
      },
      %{
        id: "best_3",
        name: "Coral Ruffle Summer Dress",
        slug: "coral-ruffle-summer-dress",
        price: Decimal.new("195.00"),
        original_price: nil,
        currency: "USD",
        rating: Decimal.new("4.8"),
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Coral", hex: "#ff7f50", selected: true},
          %{id: "c2", name: "Blush", hex: "#de9e9c", selected: false},
          %{id: "c3", name: "Peach", hex: "#ffdab9", selected: false}
        ],
        href: "/products/coral-ruffle-summer-dress"
      },
      %{
        id: "best_4",
        name: "Floral Embroidered Kimono",
        slug: "floral-embroidered-kimono",
        price: Decimal.new("245.00"),
        original_price: nil,
        currency: "USD",
        rating: Decimal.new("4.6"),
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Black", hex: "#1a1a1a", selected: true},
          %{id: "c2", name: "Navy", hex: "#1e3a5f", selected: false},
          %{id: "c3", name: "Burgundy", hex: "#722f37", selected: false}
        ],
        href: "/products/floral-embroidered-kimono"
      }
    ]
  end

  def bundle_products do
    [
      %{
        id: "bundle_1",
        name: "Stretch Ribbed V-Neck Top",
        slug: "stretch-ribbed-v-neck-top",
        price: Decimal.new("119.00"),
        currency: "USD",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Rust", hex: "#b7410e", selected: true},
          %{id: "c2", name: "Lavender", hex: "#b4a7c7", selected: false},
          %{id: "c3", name: "Camel", hex: "#c9a86c", selected: false}
        ],
        href: "/products/stretch-ribbed-v-neck-top"
      },
      %{
        id: "bundle_2",
        name: "Sharp Cut Tailored Luxe Blazer",
        slug: "sharp-cut-tailored-luxe-blazer",
        price: Decimal.new("266.00"),
        currency: "USD",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Rust", hex: "#b7410e", selected: true},
          %{id: "c2", name: "Lavender", hex: "#b4a7c7", selected: false},
          %{id: "c3", name: "Sage", hex: "#9caf88", selected: false}
        ],
        href: "/products/sharp-cut-tailored-luxe-blazer"
      },
      %{
        id: "bundle_3",
        name: "High-Waist Wide-Leg Trousers",
        slug: "high-waist-wide-leg-trousers",
        price: Decimal.new("145.00"),
        currency: "USD",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Rust", hex: "#b7410e", selected: true},
          %{id: "c2", name: "Lavender", hex: "#b4a7c7", selected: false},
          %{id: "c3", name: "Camel", hex: "#c9a86c", selected: false}
        ],
        href: "/products/high-waist-wide-leg-trousers"
      },
      %{
        id: "bundle_4",
        name: "Wide Strap Square Buckle Belt",
        slug: "wide-strap-square-buckle-belt",
        price: Decimal.new("65.00"),
        currency: "USD",
        main_image: "/images/main.jpeg",
        colors: [
          %{id: "c1", name: "Rust", hex: "#b7410e", selected: true},
          %{id: "c2", name: "Lavender", hex: "#b4a7c7", selected: false},
          %{id: "c3", name: "Camel", hex: "#c9a86c", selected: false}
        ],
        href: "/products/wide-strap-square-buckle-belt"
      }
    ]
  end

  # =============================================================================
  # TESTIMONIALS
  # =============================================================================
  def testimonials do
    [
      %{
        id: "test_1",
        name: "Casey Jordan",
        role: "Customer",
        rating: Decimal.new("4.5"),
        content:
          "We checked out a bunch of stores and finally found the perfect jeans! It was such a fun shopping trip, from picking out the style to the thrill of getting them delivered.",
        avatar: "/images/main.jpeg",
        product: %{
          name: "Shadow Bloom Crinkle Midi",
          price: Decimal.new("315.00"),
          image: "/images/main.jpeg",
          href: "/products/shadow-bloom-crinkle-midi"
        }
      },
      %{
        id: "test_2",
        name: "Alex Morgan",
        role: "Customer",
        rating: Decimal.new("4.0"),
        content:
          "We checked out a bunch of stores and finally found the perfect jeans! It was such a fun shopping trip, from picking out the style to the thrill of getting them delivered.",
        avatar: "/images/main.jpeg",
        product: %{
          name: "Longline Light Wash Jacket",
          price: Decimal.new("159.00"),
          image: "/images/main.jpeg",
          href: "/products/longline-light-wash-jacket"
        }
      },
      %{
        id: "test_3",
        name: "Taylor Swift",
        role: "Customer",
        rating: Decimal.new("5.0"),
        content:
          "Absolutely love the quality! The fabric feels premium and the fit is exactly as described. Will definitely be ordering more pieces from this collection.",
        avatar: "/images/main.jpeg",
        product: %{
          name: "Rust Red Gold Satin Dress",
          price: Decimal.new("179.00"),
          image: "/images/main.jpeg",
          href: "/products/rust-red-gold-satin-dress"
        }
      },
      %{
        id: "test_4",
        name: "Taylor Swift",
        role: "Customer",
        rating: Decimal.new("5.0"),
        content:
          "Absolutely love the quality! The fabric feels premium and the fit is exactly as described. Will definitely be ordering more pieces from this collection.",
        avatar: "/images/main.jpeg",
        product: %{
          name: "Rust Red Gold Satin Dress",
          price: Decimal.new("179.00"),
          image: "/images/main.jpeg",
          href: "/products/rust-red-gold-satin-dress"
        }
      }
    ]
  end

  # =============================================================================
  # PARTNERS
  # =============================================================================
  def partners do
    [
      %{
        id: "partner_1",
        name: "Smile",
        logo: "/images/partners/smile.svg",
        font_class: "font-['Pacifico']"
      },
      %{
        id: "partner_2",
        name: "Anna's",
        logo: "/images/partners/annas.svg",
        font_class: "font-['Sacramento']"
      },
      %{
        id: "partner_3",
        name: "Saturday",
        logo: "/images/partners/saturday.svg",
        font_class: "font-['Great_Vibes']"
      },
      %{
        id: "partner_4",
        name: "rosé",
        logo: "/images/partners/rose.svg",
        font_class: "font-light tracking-widest"
      },
      %{
        id: "partner_5",
        name: "Mockup",
        logo: "/images/partners/mockup.svg",
        font_class: "font-['Yellowtail']"
      }
    ]
  end

  # =============================================================================
  # INSTAGRAM
  # =============================================================================
  def instagram_images do
    [
      %{id: "ig_1", url: "/images/instagram/ig-1.jpg", featured: false, href: "#"},
      %{id: "ig_2", url: "/images/instagram/ig-2.jpg", featured: true, href: "#"},
      %{id: "ig_3", url: "/images/instagram/ig-3.jpg", featured: false, href: "#"},
      %{id: "ig_4", url: "/images/instagram/ig-4.jpg", featured: false, href: "#"}
    ]
  end

  # =============================================================================
  # MARQUEE ITEMS
  # =============================================================================
  def marquee_items do
    [
      %{icon: "✨", text: "Healthy Skin, Confident You"},
      %{icon: "🧴", text: "Glow Essentials for Every Routine"},
      %{icon: "🌿", text: "Quality You Can Trust"},
      %{icon: "☀️", text: "Protect Your Glow Daily"}
    ]
  end

  # =============================================================================
  # NAVIGATION
  # =============================================================================
  def navigation do
    %{
      main_links: [
        %{name: "Home", href: "/", active: true},
        %{name: "Shop", href: "/shop", has_dropdown: true, dropdown_items: shop_dropdown()},
        %{name: "Pages", href: "#", has_dropdown: true, dropdown_items: pages_dropdown()},
        %{name: "Contact", href: "/contact", active: false}
      ],
      quick_links: [
        %{name: "Home", href: "/"},
        %{name: "About", href: "/about"},
        %{name: "Shop", href: "/shop"},
        %{name: "Blog", href: "/blog"},
        %{name: "Contact", href: "/contact"}
      ],
      utility_pages: [
        %{name: "Password Protected", href: "/password-protected"},
        %{name: "404 Not Found", href: "/404"},
        %{name: "Style Guide", href: "/style-guide"},
        %{name: "Licenses", href: "/licenses"},
        %{name: "Changelog", href: "/changelog"}
      ]
    }
  end

  defp shop_dropdown do
    [
      %{name: "All Products", href: "/shop"},
      %{name: "New Arrivals", href: "/shop/new-arrivals"},
      %{name: "Best Sellers", href: "/shop/best-sellers"},
      %{name: "Sale", href: "/shop/sale"}
    ]
  end

  defp pages_dropdown do
    [
      %{name: "About Us", href: "/about"},
      %{name: "Contact", href: "/contact"},
      %{name: "FAQ", href: "/faq"},
      %{name: "Blog", href: "/blog"}
    ]
  end

  # =============================================================================
  # FOOTER
  # =============================================================================
  def footer do
    %{
      contact: %{
        phone: "+256 742 013968",
        email: "sheglowug@gmail.com",
        address: "Kampala, Uganda"
      },
      social_links: [
        %{name: "Facebook", href: "#", icon: "facebook"},
        %{name: "Instagram", href: "#", icon: "instagram"},
        %{name: "TikTok", href: "#", icon: "tiktok"},
        %{name: "Twitter", href: "#", icon: "twitter"}
      ],
      copyright: "Copyright © SheGlow UG 2026",
      designed_by: %{name: "Michael Munavu", href: "www.michaelmunavu.com"},
      powered_by: %{name: "Virgil Africa", href: "www.virgil.africa"}
    }
  end

  # =============================================================================
  # CART (for demonstration)
  # =============================================================================
  def sample_cart do
    %{
      items: [
        %{
          id: "cart_1",
          product_id: "prod_1",
          name: "Fitted Classic Blue Denim Jacket",
          price: Decimal.new("132.00"),
          quantity: 1,
          color: "Navy",
          size: "M",
          image: "/images/products/dress-black.jpg"
        },
        %{
          id: "cart_2",
          product_id: "prod_3",
          name: "Shadow Bloom Crinkle Midi",
          price: Decimal.new("315.00"),
          quantity: 2,
          color: "Burgundy",
          size: "S",
          image: "/images/products/dress-midi-black.jpg"
        }
      ],
      subtotal: Decimal.new("762.00"),
      shipping: Decimal.new("0.00"),
      tax: Decimal.new("60.96"),
      total: Decimal.new("822.96"),
      item_count: 3
    }
  end
end
