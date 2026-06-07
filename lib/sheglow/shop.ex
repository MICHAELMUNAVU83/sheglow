defmodule Sheglow.Shop do
  @moduledoc """
  The Shop context.
  Bridges the admin data models to the display shapes expected by frontend components.
  """

  import Ecto.Query, warn: false
  alias Sheglow.Repo
  alias Sheglow.Collections.Collection
  alias Sheglow.Products.Product
  alias Sheglow.ProductImages
  alias Sheglow.ProductImages.ProductImage
  alias Sheglow.ProductVariants
  alias Sheglow.ProductVariants.ProductVariant
  alias Sheglow.Testimonials.Testimonial
  alias Sheglow.Bundles.Bundle

  # ---------------------------------------------------------------------------
  # COLLECTIONS
  # ---------------------------------------------------------------------------

  @doc "Returns collections mapped to the shape expected by home/category components."
  def list_collections_for_display do
    collections =
      from(c in Collection, where: c.is_active == true, order_by: c.position)
      |> Repo.all()

    Enum.map(collections, fn c ->
      item_count =
        from(p in Product, where: p.collection_id == ^c.id, select: count())
        |> Repo.one()
        |> Kernel.||(0)

      %{
        id: c.id,
        name: c.title,
        slug: c.slug,
        image: c.image,
        item_count: item_count,
        href: "/collections/#{c.slug}",
        is_active: c.is_active
      }
    end)
  end

  @doc "Returns a collection by slug in the shape the category hero/page expects, or nil."
  def get_collection_by_slug(slug) do
    case from(c in Collection, where: c.slug == ^slug) |> Repo.one() do
      nil ->
        nil

      c ->
        %{
          id: c.id,
          name: c.title,
          slug: c.slug,
          title: "#{c.title} Essentials",
          subtitle: "BUILD YOUR GLOW ROUTINE",
          hero_image: c.image || "/images/main.jpeg",
          href: "/collections/#{c.slug}"
        }
    end
  end

  # ---------------------------------------------------------------------------
  # PRODUCTS
  # ---------------------------------------------------------------------------

  @doc "Returns all active products in the display shape."
  def list_products_for_display do
    from(p in Product, where: p.status == "active", order_by: p.position)
    |> Repo.all()
    |> enrich_products_for_display()
  end

  @doc "Returns products marked as new_arrival."
  def list_new_arrivals do
    from(p in Product,
      where: p.is_new_arrival == true and p.status == "active",
      order_by: p.position
    )
    |> Repo.all()
    |> enrich_products_for_display()
  end

  @doc "Returns products marked as bestseller, with a Decimal rating for component display."
  def list_bestsellers do
    from(p in Product,
      where: p.is_bestseller == true and p.status == "active",
      order_by: p.position
    )
    |> Repo.all()
    |> enrich_products_for_display()
    |> Enum.map(&Map.put(&1, :rating, Decimal.new("4.5")))
  end

  @doc "Returns featured products to display in the Bundle & Save section."
  def list_bundle_display_products do
    from(p in Product,
      where: p.is_featured == true and p.status == "active",
      order_by: p.position,
      limit: 8
    )
    |> Repo.all()
    |> enrich_products_for_display()
  end

  @doc "Returns active products for a collection in display shape."
  def list_products_for_collection_display(collection_id) do
    from(p in Product,
      where: p.collection_id == ^collection_id and p.status == "active",
      order_by: p.position
    )
    |> Repo.all()
    |> enrich_products_for_display()
  end

  @doc """
  Returns products filtered by a list of collection slugs, an optional pill filter,
  and a sort order.  Used by the category page when checkboxes/pills/sort change.
  """
  def list_products_for_category_filter(slugs, pill \\ "all", sort \\ "best_selling") do
    # Resolve slugs → collection IDs
    collection_ids =
      if slugs == [] do
        []
      else
        from(c in Collection, where: c.slug in ^slugs, select: c.id)
        |> Repo.all()
      end

    base =
      from(p in Product,
        where: p.status == "active" and p.collection_id in ^collection_ids
      )

    base
    |> apply_pill_filter(pill)
    |> apply_sort(sort)
    |> Repo.all()
    |> enrich_products_for_display()
  end

  defp apply_pill_filter(query, "on_sale") do
    where(query, [p], not is_nil(p.badge_label) and p.badge_label != "")
  end

  defp apply_pill_filter(query, "discounts") do
    where(query, [p], p.is_bestseller == true or p.is_featured == true)
  end

  defp apply_pill_filter(query, _all), do: query

  defp apply_sort(query, "price_asc"), do: order_by(query, [p], asc: p.base_price)
  defp apply_sort(query, "price_desc"), do: order_by(query, [p], desc: p.base_price)
  defp apply_sort(query, "newest"), do: order_by(query, [p], desc: p.inserted_at)
  defp apply_sort(query, _), do: order_by(query, [p], asc: p.position)

  @doc "Returns a small list of products for the popular sidebar block."
  def list_popular_products_for_display(limit \\ 3) do
    products =
      from(p in Product, where: p.status == "active", order_by: p.position, limit: ^limit)
      |> Repo.all()

    product_ids = Enum.map(products, & &1.id)

    first_images = batch_first_images(product_ids)

    Enum.map(products, fn p ->
      main_image = Map.get(first_images, p.id) || p.image || "/images/main.jpeg"

      %{
        id: p.id,
        name: p.name,
        slug: p.slug,
        image: main_image,
        price: p.base_price || 0,
        currency: "UGX",
        rating: 4.5,
        href: "/products/#{p.slug}"
      }
    end)
  end

  @doc "Returns a full product detail map by slug, or nil if not found."
  def get_product_by_slug(slug) do
    case from(p in Product, where: p.slug == ^slug) |> Repo.one() do
      nil ->
        nil

      product ->
        images = ProductImages.list_product_images_for_product(product.id)
        variants = ProductVariants.list_product_variants_for_product(product.id)

        collection =
          if product.collection_id, do: Repo.get(Collection, product.collection_id), else: nil

        colors =
          variants
          |> Enum.filter(&(&1.color_name not in [nil, ""]))
          |> Enum.uniq_by(& &1.color_name)
          |> Enum.with_index()
          |> Enum.map(fn {v, idx} ->
            %{
              id: "c#{idx + 1}",
              name: v.color_name,
              hex: v.color_hex || "#000000",
              selected: idx == 0
            }
          end)

        sizes =
          variants
          |> Enum.filter(&(&1.size not in [nil, ""]))
          |> Enum.uniq_by(& &1.size)
          |> Enum.with_index()
          |> Enum.map(fn {v, idx} ->
            %{
              id: "s#{idx + 1}",
              name: v.size,
              available: v.stock_quantity not in [nil, "0", ""],
              selected: idx == 0
            }
          end)

        gallery_images = Enum.map(images, & &1.image)
        main_image = List.first(gallery_images) || product.image || "/images/main.jpeg"
        all_gallery = if gallery_images == [], do: [main_image], else: gallery_images

        testimonials =
          from(t in Testimonial,
            where: t.product_id == ^product.id and t.is_active == true
          )
          |> Repo.all()

        avg_rating =
          if testimonials != [],
            do: Enum.sum(Enum.map(testimonials, & &1.rating)) / length(testimonials),
            else: 0.0

        rating_decimal = Decimal.from_float(Float.round(avg_rating, 1))

        product
        |> Map.from_struct()
        |> Map.put(:main_image, main_image)
        |> Map.put(:gallery_images, all_gallery)
        |> Map.put(:price, product.base_price || 0)
        |> Map.put(:original_price, nil)
        |> Map.put(:colors, colors)
        |> Map.put(:sizes, sizes)
        |> Map.put(:rating, rating_decimal)
        |> Map.put(:reviews_count, length(testimonials))
        |> Map.put(:sku, "SKU-#{product.id}")
        |> Map.put(:product_type, if(collection, do: collection.title, else: "Product"))
        |> Map.put(:badge, product.badge_label)
        |> Map.put(:currency, "UGX")
    end
  end

  @doc "Returns related products (active, excluding current), limited."
  def list_related_products(current_product_id, limit \\ 4) do
    from(p in Product,
      where: p.status == "active" and p.id != ^current_product_id,
      order_by: [desc: p.is_featured],
      limit: ^limit
    )
    |> Repo.all()
    |> enrich_products_for_display()
  end

  # ---------------------------------------------------------------------------
  # BUNDLES
  # ---------------------------------------------------------------------------

  @doc """
  Returns up to `limit` images from active products for fullscreen hero/contact
  Swiper slides. Pulls first ProductImage per product, falling back to product.image.
  """
  def list_hero_images(limit \\ 6) do
    # First try uploaded product images
    images =
      from(pi in ProductImage,
        join: p in Product,
        on: pi.product_id == p.id,
        where: p.status == "active",
        order_by: [asc: p.position, asc: pi.position],
        limit: ^limit,
        select: %{image: pi.image, alt: p.name, slug: p.slug}
      )
      |> Repo.all()

    # If not enough uploaded images, pad with product.image fallbacks
    if length(images) >= 2 do
      images
    else
      from(p in Product,
        where: p.status == "active" and not is_nil(p.image),
        order_by: p.position,
        limit: ^limit,
        select: %{image: p.image, alt: p.name, slug: p.slug}
      )
      |> Repo.all()
    end
  end

  @doc "Returns the first active bundle (for the home-page Bundle & Save section image)."
  def get_active_bundle do
    from(b in Bundle, where: b.is_active == true, order_by: b.id, limit: 1)
    |> Repo.one()
  end

  @doc "Returns the first active bundle with its products enriched for display."
  def get_active_bundle_with_products do
    bundle =
      from(b in Bundle, where: b.is_active == true, order_by: b.id, limit: 1)
      |> Repo.one()

    case bundle do
      nil -> nil
      b -> Map.put(b, :products, list_products_for_bundle(b.id))
    end
  end

  @doc "Returns enriched display products belonging to a bundle by id."
  def list_products_for_bundle(bundle_id) do
    alias Sheglow.BundleItems.BundleItem

    from(p in Product,
      join: bi in BundleItem,
      on: bi.product_id == p.id,
      where: bi.bundle_id == ^bundle_id and p.status == "active",
      order_by: p.position
    )
    |> Repo.all()
    |> enrich_products_for_display()
  end

  @doc "Returns a bundle by id with enriched products, or nil."
  def get_bundle_for_display(id) do
    case Repo.get(Bundle, id) do
      nil -> nil
      bundle -> Map.put(bundle, :products, list_products_for_bundle(bundle.id))
    end
  end

  @doc """
  Builds the sale banner data map from the DB.
  Uses the first featured active product as the floating card and its uploaded
  images as the right-side slides. Falls back gracefully if nothing exists.
  """
  def get_sale_banner_data do
    featured =
      from(p in Product,
        where: p.is_featured == true and p.status == "active",
        order_by: p.position
      )
      |> Repo.all()
      |> case do
        [] ->
          from(p in Product, where: p.status == "active", order_by: p.position)
          |> Repo.all()

        products ->
          products
      end
      |> case do
        [] -> nil
        products -> Enum.random(products)
      end

    {featured_product_map, slides} =
      if featured do
        images =
          from(pi in ProductImage, where: pi.product_id == ^featured.id, order_by: pi.position)
          |> Repo.all()

        variants =
          from(pv in ProductVariant, where: pv.product_id == ^featured.id)
          |> Repo.all()

        colors =
          variants
          |> Enum.filter(&(&1.color_name not in [nil, ""]))
          |> Enum.uniq_by(& &1.color_name)
          |> Enum.with_index()
          |> Enum.map(fn {v, idx} ->
            %{
              id: "c#{idx + 1}",
              name: v.color_name,
              hex: v.color_hex || "#000000",
              selected: idx == 0
            }
          end)

        main_image =
          (List.first(images) && List.first(images).image) ||
            featured.image ||
            "/images/main.jpeg"

        slides =
          case images do
            [] -> [%{image: main_image, alt: featured.name}]
            imgs -> Enum.map(imgs, fn img -> %{image: img.image, alt: featured.name} end)
          end

        fp = %{
          id: featured.id,
          slug: featured.slug,
          name: featured.name,
          price: Decimal.new(to_string(featured.base_price || 0)),
          original_price: nil,
          badge: featured.badge_label,
          image: main_image,
          colors: colors
        }

        {fp, slides}
      else
        # Fallback: collect images from any active products for the slide show
        fallback_images =
          from(pi in ProductImage,
            join: p in Product,
            on: pi.product_id == p.id,
            where: p.status == "active",
            order_by: [asc: p.position, asc: pi.position],
            limit: 5,
            select: %{image: pi.image, alt: p.name}
          )
          |> Repo.all()

        slides =
          case fallback_images do
            [] -> [%{image: "/images/main.jpeg", alt: "SheGlow"}]
            imgs -> imgs
          end

        {%{}, slides}
      end

    %{
      label: "BIGGEST SALE OFFER",
      title: "New & Modern Products\nin Our Online Store",
      discount_text: "Midseason Sale",
      discount_percent: "25% Off!",
      note: "Only Selected Product",
      featured_product: featured_product_map,
      background_image: List.first(slides)[:image] || "/images/main.jpeg",
      slides: slides
    }
  end

  # ---------------------------------------------------------------------------
  # TESTIMONIALS
  # ---------------------------------------------------------------------------

  @doc "Returns active testimonials that have a linked product, in display shape."
  def list_testimonials_for_display do
    testimonials =
      from(t in Testimonial,
        where: t.is_active == true and not is_nil(t.product_id),
        order_by: t.position,
        preload: [:product]
      )
      |> Repo.all()

    product_ids = Enum.map(testimonials, & &1.product_id)
    first_images = batch_first_images(product_ids)

    Enum.map(testimonials, fn t ->
      product_image =
        Map.get(first_images, t.product_id) || t.product.image || "/images/main.jpeg"

      product_data = %{
        name: t.product.name,
        price: t.product.base_price || 0,
        image: product_image,
        href: "/products/#{t.product.slug}"
      }

      %{
        id: t.id,
        name: t.name,
        role: "Customer",
        rating: Decimal.new(to_string(t.rating || 5)),
        content: t.body,
        avatar: t.image || "/images/main.jpeg",
        product: product_data
      }
    end)
  end

  # ---------------------------------------------------------------------------
  # PRIVATE HELPERS
  # ---------------------------------------------------------------------------

  # Takes a list of Product structs, runs exactly 2 extra queries (images + variants),
  # and returns fully shaped display maps.
  defp enrich_products_for_display([]), do: []

  defp enrich_products_for_display(products) do
    product_ids = Enum.map(products, & &1.id)

    first_images = batch_first_images(product_ids)
    colors_by_product = batch_colors(product_ids)

    Enum.map(products, fn p ->
      main_image = Map.get(first_images, p.id) || p.image || "/images/main.jpeg"
      colors = Map.get(colors_by_product, p.id, [])

      %{
        id: p.id,
        name: p.name,
        slug: p.slug,
        description: p.description,
        price: p.base_price || 0,
        original_price: nil,
        currency: "UGX",
        badge: p.badge_label,
        main_image: main_image,
        colors: colors,
        href: "/products/#{p.slug}",
        is_featured: p.is_featured,
        is_active: p.status == "active"
      }
    end)
  end

  # Returns %{product_id => first_image_url} for a list of product IDs (one query).
  defp batch_first_images([]), do: %{}

  defp batch_first_images(product_ids) do
    from(pi in ProductImage,
      where: pi.product_id in ^product_ids,
      order_by: [asc: pi.product_id, asc: pi.position]
    )
    |> Repo.all()
    |> Enum.group_by(& &1.product_id)
    |> Enum.map(fn {pid, imgs} -> {pid, List.first(imgs).image} end)
    |> Map.new()
  end

  # Returns %{product_id => [color_map, ...]} for a list of product IDs (one query).
  defp batch_colors([]), do: %{}

  defp batch_colors(product_ids) do
    from(pv in ProductVariant, where: pv.product_id in ^product_ids)
    |> Repo.all()
    |> Enum.group_by(& &1.product_id)
    |> Map.new(fn {pid, variants} ->
      colors =
        variants
        |> Enum.filter(&(&1.color_name not in [nil, ""]))
        |> Enum.uniq_by(& &1.color_name)
        |> Enum.with_index()
        |> Enum.map(fn {v, idx} ->
          %{
            id: "c#{idx + 1}",
            name: v.color_name,
            hex: v.color_hex || "#000000",
            selected: idx == 0
          }
        end)

      {pid, colors}
    end)
  end
end
