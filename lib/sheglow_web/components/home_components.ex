defmodule SheglowWeb.HomeComponents do
  use Phoenix.Component
  use Gettext, backend: SheglowWeb.Gettext

  alias Sheglow.Shop.DummyData

  def promo_bar(assigns) do
    ~H"""
    <div class="bg-[#C8001F] py-2 text-center text-xs font-medium text-white tracking-wide">
      Healthy Skin Starts Here. Explore glow essentials made for daily care.
      <a href="/#collections" class="ml-1 underline decoration-white/50 hover:decoration-white">
        Shop Now
      </a>
    </div>
    """
  end

  attr :cart_items, :list, default: []
  attr :collections, :list, default: []

  def navbar(assigns) do
    ~H"""
    <%!-- CartHook root — persists across navigations, drives badge + drawer --%>
    <div id="cart-hook-root" phx-hook="CartHook" class="hidden"></div>

    <%!-- ── Mobile menu overlay ── --%>
    <div
      id="mobile-menu-backdrop"
      class="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm opacity-0 pointer-events-none transition-opacity duration-300 lg:hidden"
      onclick="closeMobileMenu()"
    >
    </div>

    <%!-- Mobile slide-in panel (left) --%>
    <div
      id="mobile-menu-panel"
      class="fixed left-0 top-0 z-50 flex h-full w-[300px] flex-col bg-white shadow-2xl transition-transform duration-300 ease-out lg:hidden"
      style="transform: translateX(-100%);"
    >
      <%!-- Panel header --%>
      <div class="flex items-center justify-between border-b border-gray-100 px-5 py-4">
        <a href="/" class="flex items-center gap-2.5">
          <img src="/images/sheglow-logo.png" alt="Sheglow" class="h-8 w-8 rounded-full object-cover" />
          <span class="brand-logo text-2xl text-gray-900">
            SheGlow UG<span class="text-[#C8001F]">.</span>
          </span>
        </a>
        <button
          onclick="closeMobileMenu()"
          class="rounded-lg p-1.5 text-gray-400 transition hover:bg-gray-100 hover:text-black"
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

      <%!-- Mobile search --%>
      <div class="px-5 py-4 border-b border-gray-100">
        <div class="relative">
          <svg
            class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            type="text"
            placeholder="Search products…"
            class="w-full rounded-full border border-gray-200 bg-gray-50 py-2.5 pl-9 pr-4 text-sm placeholder-gray-400 focus:border-gray-400 focus:outline-none"
          />
        </div>
      </div>

      <%!-- Mobile nav links --%>
      <nav class="flex-1 overflow-y-auto px-4 py-4 space-y-1">
        <a
          href="/"
          class="flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50 transition"
        >
          <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
            />
          </svg>
          Home
        </a>

        <%!-- Shop section in mobile --%>
        <div>
          <button
            onclick="this.nextElementSibling.classList.toggle('hidden'); this.querySelector('svg').classList.toggle('rotate-180')"
            class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-gray-900 hover:bg-gray-50 transition"
          >
            <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"
              />
            </svg>
            <span class="flex-1 text-left">Shop</span>
            <svg
              class="h-4 w-4 text-gray-400 transition-transform duration-200"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </button>
          <div class="hidden ml-7 mt-1 space-y-1 border-l border-gray-100 pl-4">
            <a
              href="/#collections"
              class="block py-2 text-sm text-gray-600 hover:text-black transition"
            >
              All Categories
            </a>
            <a
              href="/#new-arrivals"
              class="block py-2 text-sm text-gray-600 hover:text-black transition"
            >
              Fresh Drops
            </a>
            <a
              href="/#bestsellers"
              class="block py-2 text-sm text-gray-600 hover:text-black transition"
            >
              Best Sellers
            </a>
            <%= for col <- @collections do %>
              <a
                href={"/collections/#{col.slug}"}
                class="block py-2 text-sm text-gray-600 hover:text-black transition"
              >
                {col[:title] || col[:name] || col.slug}
              </a>
            <% end %>
          </div>
        </div>

        <a
          href="/#new-arrivals"
          class="flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-gray-600 hover:bg-gray-50 hover:text-black transition"
        >
          <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"
            />
          </svg>
          Fresh Drops
        </a>

        <a
          href="/#contact"
          class="flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-gray-600 hover:bg-gray-50 hover:text-black transition"
        >
          <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
            />
          </svg>
          Contact
        </a>
      </nav>

      <%!-- Mobile bottom: cart + checkout + admin --%>
      <div class="border-t border-gray-100 px-5 py-4 space-y-2">
        <a
          href="/cart"
          class="flex items-center justify-center gap-2 rounded-full border border-gray-300 py-3 text-sm font-medium text-gray-700 transition hover:border-black hover:text-black"
        >
          <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
          View Cart
        </a>
        <a
          href="/checkout"
          class="flex items-center justify-center gap-2 rounded-full bg-[#C8001F] py-3 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
        >
          Checkout →
        </a>
        <a
          href="/admin"
          class="flex items-center justify-center gap-2 rounded-full border border-gray-200 py-2.5 text-xs font-medium text-gray-400 transition hover:border-[#C8001F]/30 hover:text-[#C8001F]"
        >
          <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
            />
          </svg>
          Admin Panel
        </a>
      </div>
    </div>

    <%!-- ── Cart Drawer (right sidebar) ── --%>
    <div
      id="cart-drawer-backdrop"
      class="fixed inset-0 z-40 bg-black/40 backdrop-blur-sm transition-opacity duration-300 opacity-0 pointer-events-none"
      onclick="window.CartDrawer && window.CartDrawer.close()"
    >
    </div>

    <div
      id="cart-drawer"
      class="fixed right-0 top-0 z-50 flex h-full w-full max-w-sm flex-col bg-white shadow-2xl transition-transform duration-300 ease-out"
      style="transform: translateX(100%);"
    >
      <div class="flex items-center justify-between border-b border-gray-100 px-5 py-4">
        <div class="flex items-center gap-2">
          <svg class="h-5 w-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
          <h2 class="text-base font-semibold text-gray-900">
            Your Cart (<span id="drawer-item-count">0</span>)
          </h2>
        </div>
        <button
          onclick="window.CartDrawer && window.CartDrawer.close()"
          class="rounded-lg p-1.5 text-gray-400 transition hover:bg-gray-100 hover:text-black"
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

      <div id="cart-drawer-items" class="flex-1 overflow-y-auto px-5 py-4">
        <div
          id="cart-drawer-empty"
          class="flex flex-col items-center justify-center py-16 text-center"
        >
          <svg class="h-14 w-14 text-gray-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
          <p class="mt-4 text-sm font-medium text-gray-600">Your cart is empty</p>
          <p class="mt-1 text-xs text-gray-400">Add some items to get started</p>
        </div>
        <div id="cart-drawer-list" class="hidden space-y-4"></div>
      </div>

      <div id="cart-drawer-footer" class="hidden border-t border-gray-100 px-5 py-5">
        <div class="mb-4 flex justify-between text-sm">
          <span class="text-gray-500">Subtotal</span>
          <span class="font-semibold text-gray-900">UGX <span id="drawer-total">0</span></span>
        </div>
        <a
          href="/checkout"
          class="block w-full rounded-full bg-[#C8001F] py-3 text-center text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
        >
          Checkout →
        </a>
        <a
          href="/cart"
          class="mt-2 block w-full rounded-full border border-gray-300 py-3 text-center text-sm font-medium text-gray-700 transition hover:border-black hover:text-black"
        >
          View Cart
        </a>
      </div>
    </div>

    <%!-- ── Main Navbar ── --%>
    <header
      id="main-navbar"
      class="sticky top-0 z-30 border-b border-gray-100 bg-white/95 backdrop-blur-md transition-shadow duration-300"
    >
      <div class="mx-auto flex max-w-7xl items-center gap-4 px-4 py-3.5 sm:px-6 lg:px-8">
        <%!-- Hamburger (mobile only) --%>
        <button
          onclick="openMobileMenu()"
          class="flex h-9 w-9 items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 hover:text-black transition lg:hidden"
          aria-label="Open menu"
        >
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h16M4 18h16"
            />
          </svg>
        </button>

        <%!-- Logo --%>
        <a href="/" class="flex items-center gap-2.5">
          <img
            src="/images/sheglow-logo.png"
            alt="Sheglow"
            class="h-9 w-9 rounded-full object-cover object-top shadow-sm ring-1 ring-black/5"
          />
          <span class="brand-logo text-2xl text-gray-900 sm:text-3xl">
            SheGlow UG<span class="text-[#C8001F]">.</span>
          </span>
        </a>

        <%!-- Desktop nav --%>
        <nav class="hidden flex-1 items-center gap-1 lg:flex lg:ml-6">
          <a
            href="/"
            class="rounded-lg px-3 py-2 text-sm font-medium text-gray-900 hover:bg-gray-50 transition"
          >
            Home
          </a>

          <%!-- Shop dropdown --%>
          <div class="group relative">
            <button class="flex items-center gap-1 rounded-lg px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-black transition">
              Shop
              <svg
                class="h-3.5 w-3.5 transition-transform duration-200 group-hover:rotate-180"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 9l-7 7-7-7"
                />
              </svg>
            </button>
            <%!-- Dropdown panel --%>
            <div class="invisible absolute left-0 top-full z-20 mt-1 w-52 origin-top scale-95 rounded-2xl border border-gray-100 bg-white p-2 opacity-0 shadow-xl transition-all duration-200 group-hover:visible group-hover:scale-100 group-hover:opacity-100">
              <a
                href="/#new-arrivals"
                class="flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm text-gray-700 hover:bg-gray-50 hover:text-black transition"
              >
                <span class="text-base">✨</span> Fresh Drops
              </a>
              <a
                href="/#bestsellers"
                class="flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm text-gray-700 hover:bg-gray-50 hover:text-black transition"
              >
                <span class="text-base">🔥</span> Best Sellers
              </a>
              <%= if @collections != [] do %>
                <div class="my-1.5 border-t border-gray-100"></div>
                <%= for col <- @collections do %>
                  <a
                    href={"/collections/#{col.slug}"}
                    class="flex items-center gap-2 rounded-xl px-3 py-2.5 text-sm text-gray-700 hover:bg-gray-50 hover:text-black transition"
                  >
                    <span class="h-2 w-2 rounded-full bg-gray-300"></span>
                    {col[:title] || col[:name] || col.slug}
                  </a>
                <% end %>
              <% end %>
            </div>
          </div>

          <a
            href="/#new-arrivals"
            class="rounded-lg px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-black transition"
          >
            Fresh Drops
          </a>
          <a
            href="/#contact"
            class="rounded-lg px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-black transition"
          >
            Contact
          </a>
        </nav>

        <%!-- Spacer on mobile --%>
        <div class="flex-1 lg:hidden"></div>

        <%!-- Right actions --%>
        <div class="flex items-center gap-1">
          <%!-- Search (desktop only) --%>
          <div class="relative hidden lg:block">
            <svg
              class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
            <input
              type="text"
              placeholder="Search…"
              class="w-44 rounded-full border border-gray-200 bg-gray-50 py-2 pl-9 pr-4 text-sm placeholder-gray-400 focus:border-gray-400 focus:bg-white focus:outline-none xl:w-52"
            />
          </div>

          <%!-- Search icon (mobile only) --%>
          <button class="flex h-9 w-9 items-center justify-center rounded-lg text-gray-600 hover:bg-gray-100 hover:text-black transition lg:hidden">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </button>

          <%!-- Admin entry --%>
          <a
            href="/admin"
            title="Admin Panel"
            class="group relative flex h-9 w-9 items-center justify-center rounded-lg text-gray-600 hover:bg-[#C8001F]/10 hover:text-[#C8001F] transition"
            aria-label="Admin Panel"
          >
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
              />
            </svg>
            <span class="pointer-events-none absolute -bottom-8 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-md bg-gray-900 px-2 py-1 text-[10px] font-medium text-white opacity-0 transition-opacity group-hover:opacity-100">
              Admin
            </span>
          </a>

          <%!-- Cart --%>
          <button
            onclick="(window.location.pathname==='/cart'||window.location.pathname==='/checkout') ? window.location='/cart' : window.CartDrawer && window.CartDrawer.open()"
            class="relative flex h-9 items-center gap-2 rounded-lg pl-2.5 pr-3 text-gray-600 hover:bg-gray-100 hover:text-black transition"
            aria-label="Cart"
          >
            <span class="relative">
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.5"
                  d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
              <span
                id="cart-count-badge"
                style="display:none;"
                class="absolute -right-2 -top-2 flex h-4 w-4 items-center justify-center rounded-full bg-[#C8001F] text-[10px] font-bold text-white"
              >
                0
              </span>
            </span>
            <span class="hidden text-sm font-medium sm:inline">Cart</span>
          </button>
        </div>
      </div>
    </header>

    <%!-- Mobile menu JS --%>
    <script>
      function openMobileMenu() {
        const panel = document.getElementById('mobile-menu-panel');
        const backdrop = document.getElementById('mobile-menu-backdrop');
        panel.style.transform = 'translateX(0)';
        backdrop.style.opacity = '1';
        backdrop.style.pointerEvents = 'auto';
        document.body.style.overflow = 'hidden';
      }
      function closeMobileMenu() {
        const panel = document.getElementById('mobile-menu-panel');
        const backdrop = document.getElementById('mobile-menu-backdrop');
        panel.style.transform = 'translateX(-100%)';
        backdrop.style.opacity = '0';
        backdrop.style.pointerEvents = 'none';
        document.body.style.overflow = '';
      }
    </script>
    """
  end

  attr :hero_images, :list, default: []
  attr :collections, :list, default: []
  attr :hero_collection, :map, default: nil

  def hero(assigns) do
    ~H"""
    <section class="relative bg-white" id="hero-section">
      <%!-- ── MOBILE: full-bleed image hero with overlay text ── --%>
      <div class="relative overflow-hidden lg:hidden" style="height: 75svh; min-height: 480px;">
        <%!-- Background image swiper — all layers forced to fill parent --%>
        <div
          id="hero-image"
          class="swiper hero-swiper"
          style="position: absolute; inset: 0; width: 100%; height: 100%;"
          phx-hook="SwiperHero"
          phx-update="ignore"
        >
          <div class="swiper-wrapper" style="height: 100%;">
            <%= if @hero_images == [] do %>
              <div class="swiper-slide" style="height: 100%;">
                <img
                  src="/images/main.jpeg"
                  alt="Collection"
                  style="width: 100%; height: 100%; object-fit: cover; object-position: center top;"
                />
              </div>
            <% else %>
              <%= for img <- @hero_images do %>
                <div class="swiper-slide" style="height: 100%;">
                  <img
                    src={img.image}
                    alt={img.alt}
                    style="width: 100%; height: 100%; object-fit: cover; object-position: center top;"
                  />
                </div>
              <% end %>
            <% end %>
          </div>
        </div>

        <%!-- Dark overlay for text legibility --%>
        <div
          class="pointer-events-none absolute inset-0"
          style="background: linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0.45) 45%, rgba(0,0,0,0.15) 100%); z-index: 1;"
        >
        </div>

        <%!-- Text content pinned to bottom --%>
        <div class="absolute inset-x-0 bottom-0 px-6 pb-10 pt-6" style="z-index: 2;">
          <div class="flex items-center gap-2 text-[10px] font-semibold uppercase tracking-widest text-white/70">
            <span class="h-px w-6 bg-white/50"></span> Healthy Skin. Confident You.
          </div>

          <h1 class="mt-3 text-4xl font-bold leading-tight text-white">
            Your Glow,<br />Our Passion.
          </h1>

          <p class="mt-3 text-sm leading-relaxed text-white/80">
            Carefully selected skincare essentials that nourish, protect, and enhance your natural beauty.
          </p>

          <%!-- Stats row --%>
          <div class="mt-5 flex gap-6 divide-x divide-white/20">
            <div class="pr-6">
              <p class="text-2xl font-bold text-white">{length(@collections)}+</p>
              <p class="text-[11px] font-medium text-white/60">Categories</p>
            </div>
            <div class="pl-6">
              <p class="text-2xl font-bold text-white">100%</p>
              <p class="text-[11px] font-medium text-white/60">Glow Focused</p>
            </div>
          </div>

          <%!-- Buttons --%>
          <div class="mt-6 flex gap-3">
            <a
              href={
                if @hero_collection,
                  do: "/collections/#{@hero_collection.slug}",
                  else: "/#collections"
              }
              class="flex-1 rounded-full bg-[#C8001F] py-3 text-center text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
            >
              Shop {(@hero_collection && @hero_collection.name) || "Essentials"}
            </a>
            <a
              href="/collections"
              class="rounded-full border border-white/40 px-5 py-3 text-sm font-medium text-white transition hover:bg-white/10"
            >
              View All
            </a>
          </div>
        </div>
      </div>

      <%!-- ── DESKTOP: side-by-side layout ── --%>
      <div class="hidden lg:grid lg:min-h-[600px] lg:grid-cols-2">
        <!-- Left Content -->
        <div class="relative flex flex-col justify-center overflow-hidden bg-[var(--brand-surface-soft)] px-16  xl:px-24">
          <!-- Background Marquee Text -->
          <div class="pointer-events-none absolute inset-0 flex items-center overflow-hidden opacity-[0.04]">
            <div class="animate-marquee-slow flex whitespace-nowrap">
              <span class="mx-4 text-[280px] font-bold uppercase leading-none tracking-tight xl:text-[350px]">
                SheGlow UG
              </span>
              <span class="mx-4 text-[280px] font-bold uppercase leading-none tracking-tight xl:text-[350px]">
                SheGlow UG
              </span>
            </div>
          </div>

          <div class="hero-content relative z-10 transition-all duration-700">
            <div class="flex items-center gap-3 text-xs font-semibold uppercase tracking-widest text-gray-700">
              <span class="h-px w-8 bg-gray-500"></span> Healthy Skin. Confident You.
            </div>

            <p class="font-tagline mt-3 text-2xl text-[#8f3657]">Glow with Confidence</p>

            <h1 class="mt-3 text-6xl font-bold leading-tight text-gray-900 xl:text-7xl">
              Your Glow,<br />Our Passion.
            </h1>

            <p class="mt-6 max-w-md text-base text-gray-700 lg:text-lg">
              SheGlow UG offers quality skincare you can trust, with everyday essentials designed to cleanse, hydrate, protect, and reveal healthy-looking skin.
            </p>

            <%!-- Stats --%>
            <div class="mt-8 flex gap-8 divide-x divide-gray-300">
              <div class="pr-8">
                <p class="text-4xl font-bold text-gray-900">{length(@collections)}+</p>
                <p class="mt-0.5 text-sm font-medium text-gray-600">Categories</p>
              </div>
              <div class="pl-8 pr-8">
                <p class="text-4xl font-bold text-gray-900">4</p>
                <p class="mt-0.5 text-sm font-medium text-gray-600">Core Steps</p>
              </div>
              <div class="pl-8">
                <p class="text-4xl font-bold text-gray-900">Daily</p>
                <p class="mt-0.5 text-sm font-medium text-gray-600">Self-Care</p>
              </div>
            </div>

            <div class="mt-8 flex flex-wrap gap-4">
              <a
                href={
                  if @hero_collection,
                    do: "/collections/#{@hero_collection.slug}",
                    else: "/#collections"
                }
                class="rounded-full bg-[#C8001F] px-8 py-3 text-base font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
              >
                Shop {(@hero_collection && @hero_collection.name) || "Essentials"}
              </a>
              <a
                href="/collections"
                class="rounded-full border-2 border-gray-900 px-8 py-3 text-base font-medium text-gray-900 transition hover:bg-gray-900 hover:text-white"
              >
                View All
              </a>
            </div>
          </div>
        </div>
        
    <!-- Right: Swiper Image Panel -->
        <div class="relative overflow-hidden">
          <div
            id="hero-image-desktop"
            class="swiper hero-swiper absolute inset-0 h-full w-full transition-all duration-700"
            phx-hook="SwiperHero"
            phx-update="ignore"
          >
            <div class="swiper-wrapper h-full">
              <%= if @hero_images == [] do %>
                <div class="swiper-slide h-full">
                  <img
                    src="/images/main.jpeg"
                    alt="Spring collection"
                    class="h-[80vh] w-full object-cover"
                  />
                </div>
              <% else %>
                <%= for img <- @hero_images do %>
                  <div class="swiper-slide h-[80vh]">
                    <img src={img.image} alt={img.alt} class="h-full w-full object-cover" />
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def collections(assigns) do
    ~H"""
    <section id="collections" class="bg-white px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <div class="mx-auto max-w-7xl">
        <div class="mb-10 flex items-end justify-between" data-motion-reveal>
          <div>
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-500">
              Glow Collection
            </p>
            <h2 class="mt-2 text-3xl font-bold text-black sm:text-4xl lg:text-5xl">
              Build Your Routine
            </h2>
          </div>
          <a
            href="/collections"
            class="hidden shrink-0 items-center gap-1 text-sm font-medium text-[#C8001F] hover:underline sm:flex"
          >
            View all
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 8l4 4m0 0l-4 4m4-4H3"
              />
            </svg>
          </a>
        </div>

        <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3" data-motion-stagger-group="0.06">
          <%= for {collection, index} <- Enum.with_index(@collections, 1) do %>
            <a
              href={collection.href}
              class="group relative overflow-hidden rounded-2xl bg-gray-100 transition hover:shadow-xl"
              data-motion-reveal
            >
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

              <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />

              <div class="absolute inset-x-0 bottom-0 p-5">
                <span class="text-xs font-semibold text-white/50">
                  {String.pad_leading("#{index}", 2, "0")}
                </span>
                <h3 class="mt-1 text-xl font-bold text-white leading-tight">{collection.name}</h3>
                <div class="mt-2 flex items-center justify-between">
                  <span class="text-xs text-white/70">
                    {collection.item_count} {if collection.item_count == 1,
                      do: "essential",
                      else: "essentials"}
                  </span>
                  <span class="inline-flex items-center gap-1 rounded-full bg-white/20 px-3 py-1 text-xs font-semibold text-white backdrop-blur-sm transition group-hover:bg-[#C8001F]">
                    Discover
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

        <div class="mt-8 text-center sm:hidden">
          <a
            href="/collections"
            class="inline-flex items-center gap-1 text-sm font-medium text-[#C8001F] hover:underline"
          >
            View all categories
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 8l4 4m0 0l-4 4m4-4H3"
              />
            </svg>
          </a>
        </div>
      </div>
    </section>
    """
  end

  def sale_banner(assigns) do
    assigns =
      assigns
      |> assign_new(:current_index, fn -> 0 end)
      |> assign_new(:sale_banner, fn ->
        %{
          slides: [%{image: "/images/main.jpeg", alt: "SheGlow essential"}],
          featured_product: %{}
        }
      end)

    ~H"""
    <% slides = Map.get(@sale_banner, :slides, []) %>
    <% current_slide =
      Enum.at(slides, @current_index) || %{image: "/images/main.jpeg", alt: "SheGlow essential"} %>
    <section class="relative overflow-hidden bg-[var(--brand-surface)]">
      <div class="grid lg:grid-cols-2">
        <!-- Left Content -->
        <div class="flex flex-col justify-center px-6 py-12 sm:px-12 lg:px-16 lg:py-24">
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">
            SheGlow Spotlight
          </p>
          <h2 class="mt-4 text-4xl font-bold text-gray-900 sm:text-5xl lg:text-6xl">
            Glow essentials for<br class="hidden sm:block" /> every skin routine
          </h2>

          <% fp = Map.get(@sale_banner, :featured_product, %{}) %>
          <a
            href={if fp[:slug], do: "/products/#{fp[:slug]}", else: "/#collections"}
            class="mt-8 w-fit rounded-full bg-[#C8001F] px-8 py-3 text-base font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
          >
            Explore Now
          </a>
          
    <!-- Sale Tag -->
          <div class="mt-12 flex items-center gap-2 text-xs">
            <span class="text-black">Poster-inspired glow picks</span>
            <span class="font-semibold text-red-500">Trusted quality</span>
            <span class="text-gray-400">•</span>
            <span class="text-gray-600">For</span>
            <a href="/#collections" class="font-medium text-black underline">every skin type</a>
          </div>
          
    <!-- Floating Product Card -->
          <div class="relative z-10 mt-8 lg:absolute lg:left-1/2 lg:top-1/2 lg:mt-0 lg:-translate-y-1/2 lg:translate-x-[-20%]">
            <% product = Map.get(@sale_banner, :featured_product, %{}) %>
            <a
              href={if product[:slug], do: "/products/#{product[:slug]}", else: "#"}
              class="block w-full rounded-xl bg-white p-4 shadow-xl transition hover:shadow-2xl lg:max-w-sm"
            >
              <!-- Discount Badge -->
              <div class="relative">
                <%= if product[:badge] do %>
                  <span class="absolute left-2 top-2 rounded bg-red-500 px-2 py-1 text-xs font-semibold text-white">
                    {product[:badge]}
                  </span>
                <% end %>
                <img
                  src={product[:image] || "/images/main.jpeg"}
                  alt={product[:name] || "Featured skincare product"}
                  class="h-64 w-full rounded-lg object-cover object-top object-top"
                />
              </div>
              
    <!-- Color Options -->
              <div class="mt-4 flex gap-2">
                <%= for color <- product[:colors] || [] do %>
                  <button
                    class={"h-7 w-7 rounded-full border-2 #{if color[:selected], do: "border-black", else: "border-transparent"} border-gray-300"}
                    style={"background-color: #{color[:hex]}"}
                  >
                  </button>
                <% end %>
              </div>

              <h3 class="mt-3 text-sm font-medium text-gray-900">
                {product[:name] || "Featured Product"}
              </h3>
              <div class="mt-1 flex items-center gap-2">
                <span class="text-base font-semibold text-red-500">
                  UGX {SheglowWeb.Format.price(product[:price] || 0)}
                </span>
                <%= if product[:original_price] do %>
                  <span class="text-sm text-gray-400 line-through">
                    UGX {SheglowWeb.Format.price(product[:original_price] || 0)}
                  </span>
                <% end %>
              </div>
            </a>
          </div>
        </div>
        
    <!-- Right Image (current slide) -->
        <div class="relative z-0 hidden lg:block lg:min-h-[500px]">
          <img
            src={current_slide[:image]}
            alt={current_slide[:alt]}
            class="absolute inset-0 h-full w-full object-top object-cover"
          />
          <!-- Slider Dots -->
          <div class="absolute right-6 top-1/2 flex -translate-y-1/2 flex-col gap-3">
            <%= for {_slide, index} <- Enum.with_index(slides) do %>
              <button
                type="button"
                phx-click="select_sale_slide"
                phx-value-index={index}
                class={"h-3 w-3 rounded-full transition-colors #{if index == @current_index, do: "bg-white", else: "border border-white/50 bg-transparent hover:bg-white/30"}"}
              >
              </button>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def new_arrivals(assigns) do
    ~H"""
    <section id="new-arrivals" class="bg-white px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <div class="mx-auto max-w-7xl">
        <div class="text-center" data-motion-reveal>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">Fresh Drops</p>
          <h2 class="mt-3 text-3xl font-bold text-black sm:text-4xl lg:text-5xl">
            New glow essentials<br />just landed
          </h2>
        </div>
        
    <!-- Products Carousel (Swiper) with external navigation -->
        <div class="relative mt-12">
          <!-- Nav Arrows - positioned outside the swiper container -->
          <button
            type="button"
            id="new-arrivals-prev"
            class="new-arrivals-nav-btn absolute -left-6 top-[200px] z-20 hidden h-12 w-12 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-600 shadow-sm transition hover:border-black hover:text-black lg:flex xl:-left-16"
            aria-label="Previous"
          >
            <svg
              class="h-5 w-5"
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
            id="new-arrivals-next"
            class="new-arrivals-nav-btn absolute -right-6 top-[200px] z-20 hidden h-12 w-12 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-600 shadow-sm transition hover:border-black hover:text-black lg:flex xl:-right-16"
            aria-label="Next"
          >
            <svg
              class="h-5 w-5"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>

          <div
            class="swiper new-arrivals-swiper overflow-hidden"
            id="swipernewarrival"
            phx-hook="SwiperNewArrivals"
          >
            <div class="swiper-wrapper">
              <%= for product <- @products do %>
                <div class="swiper-slide">
                  <a href={"/products/#{product.slug}"} class="group block">
                    <%!-- Image --%>
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
                    <%!-- Color Swatches --%>
                    <div class="mt-4 flex gap-2">
                      <%= for color <- product.colors do %>
                        <span
                          class={"h-6 w-6 rounded-full border-2 #{if color.selected, do: "border-black", else: "border-transparent"}"}
                          style={"background-color: #{color.hex}"}
                        >
                        </span>
                      <% end %>
                    </div>
                    <%!-- Product Info --%>
                    <h3 class="mt-3 text-sm font-medium text-black group-hover:text-[#C8001F] transition-colors">
                      {product.name}
                    </h3>
                    <div class="mt-1 flex items-center gap-2">
                      <span class={"font-semibold #{if product.original_price, do: "text-red-500", else: "text-black"}"}>
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

  def banner(assigns) do
    assigns = assign_new(assigns, :items, fn -> DummyData.marquee_items() end)

    ~H"""
    <section class="overflow-hidden border-y border-gray-100 bg-white py-4">
      <div class="group flex">
        <div class="flex animate-scroll-left">
          <%= for _copy <- 1..4 do %>
            <div class="flex shrink-0">
              <%= for item <- @items do %>
                <div class="flex shrink-0 items-center gap-3 px-8">
                  <span class="text-2xl">{item.icon}</span>
                  <span class="whitespace-nowrap text-sm font-medium text-gray-700">{item.text}</span>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </section>

    <style>
      @keyframes scroll-left {
        0% {
          transform: translateX(0);
        }
        100% {
          transform: translateX(-50%);
        }
      }

      .animate-scroll-left {
        animation: scroll-left 30s linear infinite;
      }

      .group:hover .animate-scroll-left {
        animation-play-state: paused;
      }
    </style>
    """
  end

  def two_column_collection(assigns) do
    ~H"""
    <section :if={@featured_collections != []} class="bg-white px-4 py-16 sm:px-6 lg:px-8">
      <div class="mx-auto grid max-w-7xl gap-6 lg:grid-cols-2" data-motion-stagger-group="0.12">
        <%= for collection <- @featured_collections do %>
          <div class="group flex flex-col overflow-hidden bg-gray-100 sm:flex-row" data-motion-reveal>
            <div class="flex flex-1 flex-col justify-center p-8 sm:p-10">
              <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">
                Glow Edit
              </p>
              <h3 class="mt-4 text-2xl font-bold text-black sm:text-3xl">
                {collection.name}
              </h3>
              <a
                href={collection.href}
                class="mt-6 flex h-12 w-12 items-center justify-center rounded-full border border-gray-300 transition hover:border-black hover:bg-black hover:text-white"
              >
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M7 17L17 7M17 7H7M17 7v10"
                  />
                </svg>
              </a>
            </div>
            <div class="relative h-[300px] cursor-pointer flex-1 sm:min-h-0">
              <img
                src={collection.image || "/images/main.jpeg"}
                alt={collection.name}
                class="absolute inset-0 hover:scale-110 transition-all ease-in-out duration-500 h-full w-full object-cover"
              />
            </div>
          </div>
        <% end %>
      </div>
    </section>
    """
  end

  def video_banner(assigns) do
    ~H"""
    <section
      class="relative mx-4 my-8 sm:mx-6 lg:mx-8"
      id="video-banner-section"
      phx-hook="VideoBannerReveal"
    >
      <!-- Circular reveal container -->
      <div class="relative min-h-[500px] overflow-hidden rounded-3xl bg-black sm:min-h-[600px] lg:min-h-[700px]">
        <!-- Video Background with clip-path animation -->
        <div
          id="video-reveal-container"
          class="absolute inset-0 transition-[clip-path] duration-1000 ease-out"
          style="clip-path: circle(0% at 50% 50%);"
        >
          <video
            id="hero-video"
            class="absolute inset-0 h-full w-full object-[40%] object-cover"
            muted
            autoplay
            loop
            playsinline
          >
            <source src="/images/video.mp4" type="video/mp4" />
          </video>
          <!-- Overlay -->
          <div class="absolute inset-0 bg-black/30"></div>
        </div>
        
    <!-- Content (always visible) -->
        <div class="relative z-10 flex h-full min-h-[500px] flex-col items-center justify-center px-6 text-center sm:min-h-[600px] lg:min-h-[700px]">
          <p class="text-xs font-semibold uppercase tracking-widest text-white/80">
            Quality you can trust
          </p>
          <h2 class="mt-4 text-3xl font-bold text-white sm:text-4xl lg:text-5xl">
            Protect your glow.<br />Nourish your skin.<br />Be confident.
          </h2>
          <a
            href="/collection"
            class="mt-6 text-sm font-medium text-white underline underline-offset-4 hover:text-white/80"
          >
            Shop the Routine
          </a>
          
    <!-- Play/Pause Button -->
          <button
            id="video-toggle"
            type="button"
            class="mt-10 flex h-16 w-16 items-center justify-center rounded-full bg-white text-black shadow-lg transition hover:scale-105 sm:h-20 sm:w-20"
            aria-label="Play or pause video"
          >
            <svg
              id="pause-icon"
              class="hidden h-6 w-6 sm:h-8 sm:w-8"
              fill="currentColor"
              viewBox="0 0 24 24"
            >
              <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
            </svg>
            <svg id="play-icon" class="h-6 w-6 sm:h-8 sm:w-8" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          </button>
        </div>
      </div>
    </section>
    """
  end

  attr :active_bundle, :map, default: nil

  def bundle_and_save(assigns) do
    ~H"""
    <section class="bg-white px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
      <div class="mx-auto max-w-7xl">
        <div class="text-center" data-motion-reveal>
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">Bundle & Save</p>
          <h2 class="mt-3 text-3xl font-bold text-black sm:text-4xl lg:text-5xl">
            <%= if @active_bundle do %>
              {@active_bundle.title}
            <% else %>
              Build Your Glow Routine<br />& Save More
            <% end %>
          </h2>
          <%= if @active_bundle && @active_bundle.description not in [nil, ""] do %>
            <p class="mx-auto mt-3 max-w-xl text-sm text-gray-500">{@active_bundle.description}</p>
          <% end %>
        </div>

        <%= if @active_bundle do %>
          <% products = Map.get(@active_bundle, :products, []) %>
          <% bundle_url = "/bundles/#{@active_bundle.id}" %>
          
    <!-- Content Grid -->
          <div class="mt-12 overflow-hidden rounded-2xl border border-gray-200">
            <div class="grid lg:grid-cols-5">
              <!-- Products Grid - Takes 3 columns -->
              <div class="lg:col-span-3 lg:h-[700px] lg:overflow-y-auto">
                <div class="grid grid-cols-2 gap-px bg-gray-200">
                  <%= for product <- products do %>
                    <a href={product.href} class="group bg-white p-5 transition hover:bg-gray-50">
                      <div class="overflow-hidden rounded-lg bg-gray-100">
                        <img
                          src={product.main_image}
                          alt={product.name}
                          class="aspect-square w-full object-cover object-top transition-transform object-top duration-300 group-hover:scale-105"
                        />
                      </div>
                      <div class="mt-4 border-t border-gray-200 pt-4">
                        <div class="flex gap-1.5">
                          <%= for color <- Enum.take(product.colors, 3) do %>
                            <span
                              class="h-5 w-5 rounded-full border border-gray-200"
                              style={"background-color: #{color[:hex]}"}
                            />
                          <% end %>
                        </div>
                        <h3 class="mt-2 text-sm font-medium text-black line-clamp-1">
                          {product.name}
                        </h3>
                        <p class="mt-0.5 text-sm font-semibold text-black">
                          UGX {SheglowWeb.Format.price(product.price)}
                        </p>
                      </div>
                    </a>
                  <% end %>
                </div>
                
    <!-- CTA row -->
                <div class="border-t border-gray-200 bg-white p-6 text-center">
                  <a
                    href={bundle_url}
                    class="inline-block rounded-full bg-[#C8001F] px-10 py-3 text-sm font-semibold text-white transition hover:bg-[var(--brand-primary-dark)]"
                  >
                    View Bundle & Add All to Cart →
                  </a>
                </div>
              </div>
              
    <!-- Featured Bundle Image - Takes 2 columns -->
              <div class="hidden lg:col-span-2 lg:block">
                <a href={bundle_url} class="block h-full">
                  <img
                    src={
                      if @active_bundle.image not in [nil, ""],
                        do: @active_bundle.image,
                        else: "/images/main.jpeg"
                    }
                    alt={@active_bundle.title}
                    class="h-full w-full object-cover object-top lg:h-[700px]"
                  />
                </a>
              </div>
            </div>
          </div>
        <% else %>
          <!-- Fallback when no active bundle -->
          <div class="mt-12 rounded-2xl border border-gray-200 bg-gray-50 p-16 text-center">
            <p class="text-sm text-gray-400">
              No active routine bundle at the moment. Check back soon!
            </p>
            <a
              href="/#collections"
              class="mt-4 inline-block rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
            >
              Shop Categories
            </a>
          </div>
        <% end %>
      </div>
    </section>
    """
  end

  def testimonials(assigns) do
    ~H"""
    <section
      class="bg-gray-50 px-4 py-12 sm:px-6 lg:px-8 lg:py-16"
      data-motion-reveal
      id="testimonials-section"
    >
      <div class="mx-auto max-w-7xl">
        <div class="text-center">
          <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">Glow Stories</p>
          <h2 class="mt-2 text-3xl font-bold text-gray-900 sm:text-4xl lg:text-5xl">
            Results Our Customers Love
          </h2>
        </div>
        <div class="mt-8 grid gap-6 sm:grid-cols-2 lg:gap-8">
          <%= for testimonial <- @testimonials do %>
            <% rating_float = Decimal.to_float(testimonial.rating) %>
            <% full_stars = trunc(rating_float) %>
            <% has_half = rating_float - full_stars >= 0.5 %>
            <div class="rounded-2xl bg-white p-5 shadow-sm sm:p-6">
              <div class="flex items-start justify-between gap-3">
                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <div class="flex text-yellow-400">
                      <%= for _i <- 1..full_stars do %>
                        <svg class="h-5 w-5 fill-current" viewBox="0 0 20 20">
                          <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" />
                        </svg>
                      <% end %>
                      <%= if has_half do %>
                        <svg class="h-5 w-5" viewBox="0 0 20 20">
                          <defs>
                            <linearGradient id={"half-star-#{testimonial.id}"}>
                              <stop offset="50%" stop-color="#FACC15" />
                              <stop offset="50%" stop-color="#E5E7EB" />
                            </linearGradient>
                          </defs>
                          <path
                            fill={"url(#half-star-#{testimonial.id})"}
                            d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"
                          />
                        </svg>
                      <% end %>
                    </div>
                    <span class="text-sm text-gray-500">({testimonial.rating})</span>
                  </div>
                  <div class="mt-2 flex items-center gap-2">
                    <h4 class="font-semibold text-gray-900">{testimonial.name}</h4>
                    <span class="text-gray-400">—</span>
                    <span class="text-sm text-gray-500">{testimonial.role}</span>
                  </div>
                </div>
                <img
                  src={testimonial.avatar}
                  alt={testimonial.name}
                  class="h-28 w-24 flex-shrink-0 rounded-lg object-cover object-top sm:h-36 sm:w-28"
                />
              </div>
              <p class="mt-3 leading-relaxed text-gray-600">{testimonial.content}</p>
              <div class="mt-4 flex items-center gap-3 rounded-lg bg-gray-50 p-2.5">
                <img
                  src={testimonial.product.image}
                  alt={testimonial.product.name}
                  class="h-14 w-12 flex-shrink-0 rounded object-cover"
                />
                <div>
                  <p class="text-sm font-medium text-gray-900">{testimonial.product.name}</p>
                  <p class="text-sm text-gray-600">
                    UGX {SheglowWeb.Format.price(testimonial.product.price)}
                  </p>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  def best_sellers(assigns) do
    ~H"""
    <section id="bestsellers" class="bg-white px-4 py-16 sm:px-6 lg:px-8 lg:py-24" data-motion-reveal>
      <div class="mx-auto max-w-7xl">
        <div class="grid gap-6 lg:grid-cols-12">
          <!-- Left Promo Card - Takes 4 columns, spans full height -->
          <div class="flex flex-col rounded-2xl bg-gray-100 p-6 sm:p-8 lg:col-span-7 lg:row-span-2">
            <div>
              <p class="text-xs font-semibold uppercase tracking-widest text-gray-700">
                Our Best Sellers
              </p>
              <h2 class="mt-4 text-3xl font-bold text-black sm:text-4xl">
                Most-loved<br />SheGlow essentials
              </h2>
              <p class="mt-4 text-gray-600">
                Discover the formulas our customers keep coming back for, from daily cleansers to hydrating finishers.
              </p>

              <a
                href="/#bestsellers"
                class="mt-8 inline-block rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
              >
                Shop Now
              </a>
            </div>
            <div class="mt-auto pt-8">
              <video
                src="/images/bestseller.mp4"
                alt="Best sellers"
                class="aspect-[4/3] w-full rounded-lg object-top object-cover"
                autoplay
                loop
                playsinline
                muted
              />
            </div>
          </div>

          <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:col-span-5">
            <%= for product <- @bestsellers do %>
              <a href={"/products/#{product.slug}"} class="group block">
                <div class="overflow-hidden rounded-lg bg-gray-100">
                  <img
                    src={product.main_image}
                    alt={product.name}
                    class="aspect-[3/4] h-[300px] w-full object-cover object-top object-top transition-transform duration-300 group-hover:scale-105"
                  />
                </div>

                <div class="mt-4 flex gap-2">
                  <%= for color <- product.colors do %>
                    <span
                      class={"inline-block h-7 w-7 rounded-full border-2 #{if color.selected, do: "border-black", else: "border-gray-200"}"}
                      style={"background-color: #{color.hex}"}
                      aria-label={"#{color.name}"}
                    >
                    </span>
                  <% end %>
                </div>

                <h3 class="mt-3 text-sm font-medium text-black group-hover:text-[#C8001F] transition-colors">
                  {product.name}
                </h3>
                <p class="mt-1 font-semibold text-black">
                  UGX {SheglowWeb.Format.price(product.price)}
                </p>
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :collection, :map, default: nil

  def countdown(assigns) do
    assigns = assign_new(assigns, :collection, fn -> nil end)

    ~H"""
    <section class="px-4 py-8 sm:px-6 lg:px-8" id="countdown-section" phx-hook="CountdownTimer">
      <div class="relative mx-auto max-w-7xl overflow-hidden rounded-3xl bg-[#C8001F]">
        <%!-- Dot pattern overlay --%>
        <div class="absolute inset-0 overflow-hidden">
          <svg
            class="absolute bottom-0 left-0 h-full w-full opacity-10"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <pattern
                id="dot-pattern"
                x="0"
                y="0"
                width="20"
                height="20"
                patternUnits="userSpaceOnUse"
              >
                <circle cx="2" cy="2" r="1.5" fill="white" />
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#dot-pattern)" />
          </svg>
        </div>

        <div class="relative z-10 grid lg:grid-cols-2">
          <%!-- Countdown side --%>
          <div class="flex flex-col items-center justify-center px-6 py-16 sm:px-12 lg:border-r lg:border-white/20 lg:py-24">
            <p class="text-xs font-semibold uppercase tracking-[0.25em] text-red-200">
              Limited Time Glow Offer
            </p>
            <div class="mt-10 flex items-baseline gap-3 sm:gap-5">
              <div class="text-center">
                <span
                  class="font-display text-5xl font-bold tabular-nums text-white sm:text-6xl lg:text-7xl"
                  id="countdown-hours"
                >
                  02
                </span>
                <p class="mt-3 text-sm font-medium text-red-200">Hours</p>
              </div>
              <span class="text-4xl font-light text-white/50 sm:text-5xl lg:text-6xl">:</span>
              <div class="text-center">
                <span
                  class="font-display text-5xl font-bold tabular-nums text-white sm:text-6xl lg:text-7xl"
                  id="countdown-minutes"
                >
                  00
                </span>
                <p class="mt-3 text-sm font-medium text-red-200">Minutes</p>
              </div>
              <span class="text-4xl font-light text-white/50 sm:text-5xl lg:text-6xl">:</span>
              <div class="text-center">
                <span
                  class="font-display text-5xl font-bold tabular-nums text-white sm:text-6xl lg:text-7xl"
                  id="countdown-seconds"
                >
                  00
                </span>
                <p class="mt-3 text-sm font-medium text-red-200">Seconds</p>
              </div>
            </div>
          </div>

          <%!-- CTA side — dynamic collection --%>
          <div class="flex flex-col items-center justify-center px-6 py-16 text-center sm:px-12 lg:items-start lg:py-24 lg:text-left">
            <%= if @collection do %>
              <p class="text-xs font-semibold uppercase tracking-[0.2em] text-red-200">
                Featured Category
              </p>
              <h2 class="mt-3 text-3xl font-bold leading-tight text-white sm:text-4xl lg:text-5xl">
                Shop the {@collection.name}
              </h2>
              <p class="mt-4 max-w-md text-base text-red-100/80 lg:text-lg">
                {if @collection[:description] && @collection.description != "",
                  do:
                    String.slice(@collection.description, 0, 100) <>
                      if(String.length(@collection.description) > 100, do: "…", else: ""),
                  else:
                    "Discover skincare essentials carefully selected to support healthy, radiant skin every day."}
              </p>
              <a
                href={"/collections/#{@collection.slug}"}
                class="mt-8 inline-flex items-center justify-center gap-2 rounded-full bg-white px-10 py-4 text-sm font-semibold text-[#C8001F] transition-all hover:bg-red-50 hover:shadow-lg"
              >
                Shop the Category
                <svg
                  class="h-4 w-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  stroke-width="2"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </a>
            <% else %>
              <h2 class="text-3xl font-bold leading-tight text-white sm:text-4xl lg:text-5xl">
                Glow with SheGlow Today
              </h2>
              <p class="mt-5 max-w-md text-base text-red-100/80 lg:text-lg">
                Explore nourishing, protective, and confidence-boosting skincare made for real routines.
              </p>
              <a
                href="/#collections"
                class="mt-8 inline-flex items-center justify-center rounded-full bg-white px-10 py-4 text-sm font-semibold text-[#C8001F] transition-all hover:bg-red-50 hover:shadow-lg"
              >
                Browse Categories
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def features(assigns) do
    ~H"""
    <section class="bg-white px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
      <div class="mx-auto max-w-7xl">
        <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4" data-motion-stagger-group="0.08">
          <div class="flex flex-col items-center text-center" data-motion-reveal>
            <div class="flex h-16 w-16 items-center justify-center">
              <svg
                class="h-12 w-12 text-black"
                viewBox="0 0 48 48"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <circle cx="24" cy="24" r="18" />
                <ellipse cx="24" cy="24" rx="8" ry="18" />
                <path d="M6 24h36" />
                <path d="M24 6c6 4 10 10 10 18s-4 14-10 18" />
                <path d="M24 6c-6 4-10 10-10 18s4 14 10 18" />
                <circle cx="38" cy="34" r="6" fill="white" stroke="currentColor" />
                <path d="M36 34h4M38 32v4" stroke-linecap="round" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-semibold text-black">Quality Products</h3>
            <p class="mt-2 text-sm text-gray-500">
              Carefully sourced, safe, and effective essentials.
            </p>
          </div>

          <div class="flex flex-col items-center text-center" data-motion-reveal>
            <div class="flex h-16 w-16 items-center justify-center">
              <svg
                class="h-12 w-12 text-black"
                viewBox="0 0 48 48"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <rect x="6" y="14" width="36" height="24" rx="4" />
                <path d="M6 22h36" />
                <rect x="10" y="30" width="8" height="4" rx="1" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-semibold text-black">For Every Skin</h3>
            <p class="mt-2 text-sm text-gray-500">
              Solutions for dry, oily, sensitive, and combination skin.
            </p>
          </div>
          <div class="flex flex-col items-center text-center" data-motion-reveal>
            <div class="flex h-16 w-16 items-center justify-center">
              <svg
                class="h-12 w-12 text-black"
                viewBox="0 0 48 48"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <rect x="8" y="8" width="20" height="26" rx="2" />
                <path d="M12 14h12M12 20h8" />
                <circle cx="34" cy="32" r="10" />
                <path d="M34 26v6l4 2" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-semibold text-black">Visible Results</h3>
            <p class="mt-2 text-sm text-gray-500">Products that support a healthier-looking glow.</p>
          </div>
          <div class="flex flex-col items-center text-center" data-motion-reveal>
            <div class="flex h-16 w-16 items-center justify-center">
              <svg
                class="h-12 w-12 text-black"
                viewBox="0 0 48 48"
                fill="none"
                stroke="currentColor"
                stroke-width="1.5"
              >
                <rect x="8" y="20" width="32" height="22" rx="2" />
                <rect x="6" y="14" width="36" height="8" rx="2" />
                <path d="M24 14v28" />
                <path d="M24 14c-4-6-12-6-12 0s8 6 12 0" />
                <path d="M24 14c4-6 12-6 12 0s-8 6-12 0" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-semibold text-black">Self-Care Everyday</h3>
            <p class="mt-2 text-sm text-gray-500">Because feeling good in your skin matters daily.</p>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :contact_images, :list, default: []

  def contact_section(assigns) do
    assigns = assign_new(assigns, :contact_images, fn -> [] end)

    ~H"""
    <section id="contact" class="bg-[var(--brand-surface-soft)]">
      <div class="grid min-h-[420px] lg:grid-cols-2">
        <%!-- Left: Form --%>
        <div class="flex flex-col justify-center px-6 py-12 sm:px-10 sm:py-16 lg:px-14 lg:py-20">
          <h2 class="text-3xl font-bold text-black sm:text-4xl">Get in Touch</h2>
          <p class="mt-4 max-w-md text-gray-700">
            Tell us about your skin goals or concerns and we will help you find a routine that fits.
          </p>
          <form class="mt-8 space-y-5" phx-submit="contact_submit">
            <div class="grid gap-5 sm:grid-cols-2">
              <input
                type="text"
                name="full_name"
                placeholder="Full Name"
                class="w-full rounded-lg border border-gray-300 bg-white px-4 py-3 text-black placeholder-gray-400 focus:border-gray-400 focus:outline-none"
              />
              <input
                type="tel"
                name="phone"
                placeholder="Phone Number"
                class="w-full rounded-lg border border-gray-300 bg-white px-4 py-3 text-black placeholder-gray-400 focus:border-gray-400 focus:outline-none"
              />
            </div>
            <div class="grid gap-5 sm:grid-cols-2">
              <input
                type="email"
                name="email"
                placeholder="Email Address"
                class="w-full rounded-lg border border-gray-300 bg-white px-4 py-3 text-black placeholder-gray-400 focus:border-gray-400 focus:outline-none"
              />
              <input
                type="text"
                name="subject"
                placeholder="Skin Concern"
                class="w-full rounded-lg border border-gray-300 bg-white px-4 py-3 text-black placeholder-gray-400 focus:border-gray-400 focus:outline-none"
              />
            </div>
            <textarea
              name="message"
              rows="4"
              placeholder="Which products are you looking for, and what skin goal are you targeting?"
              class="w-full resize-y rounded-lg border border-gray-300 bg-white px-4 py-3 text-black placeholder-gray-400 focus:border-gray-400 focus:outline-none"
            >
            </textarea>
            <button
              type="submit"
              class="rounded-full bg-[#C8001F] px-8 py-3 text-sm font-medium text-white transition hover:bg-[var(--brand-primary-dark)]"
            >
              Send Message
            </button>
          </form>
        </div>
        <%!-- Right: Swiper Image Panel --%>
        <div class="relative min-h-[380px] overflow-hidden lg:min-h-full">
          <div
            id="contact-swiper"
            class="swiper contact-swiper absolute inset-0 h-full w-full"
            phx-hook="SwiperContact"
            phx-update="ignore"
          >
            <div class="swiper-wrapper h-full">
              <%= if @contact_images == [] do %>
                <div class="swiper-slide h-full">
                  <img
                    src="/images/main.jpeg"
                    alt="SheGlow"
                    class="h-full w-full object-cover object-top object-center"
                  />
                </div>
              <% else %>
                <%= for img <- @contact_images do %>
                  <div class="swiper-slide h-full">
                    <img
                      src={img.image}
                      alt={img.alt}
                      class="h-full w-full object-cover object-top object-center"
                    />
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="bg-[#2f1620]">
      <%!-- Brand strip --%>
      <div class="border-b border-white/10 px-4 py-8">
        <div class="mx-auto flex max-w-7xl flex-col items-center gap-3 sm:flex-row sm:items-center sm:justify-between">
          <a href="/" class="flex items-center gap-3">
            <img
              src="/images/sheglow-logo.png"
              alt="SheGlow UG"
              class="h-10 w-10 rounded-full object-cover object-top ring-2 ring-[#C8001F]"
            />
            <div>
              <span class="brand-logo text-3xl text-white">
                SheGlow UG<span class="text-[#C8001F]">.</span>
              </span>
              <p class="text-[10px] uppercase tracking-widest text-gray-500">
                Healthy Skin. Confident You.
              </p>
            </div>
          </a>
          <p class="text-center text-sm text-gray-400 sm:text-right">
            Quality skincare you can trust, with results you can see.
          </p>
        </div>
      </div>
      <%!-- Main Footer Content --%>
      <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8 lg:py-16">
        <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          <%!-- Contact & Socials --%>
          <div>
            <h3 class="text-xl font-semibold text-white">Get In Touch</h3>
            <ul class="mt-6 space-y-4">
              <li>
                <a
                  href="https://wa.me/256742013968"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-3 text-gray-400 transition hover:text-white"
                >
                  <svg class="h-5 w-5 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
                  </svg>
                  <span>WhatsApp: +256 742 013968</span>
                </a>
              </li>
              <li>
                <a
                  href="https://instagram.com/sheglowug"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-3 text-gray-400 transition hover:text-white"
                >
                  <svg class="h-5 w-5 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
                  </svg>
                  <span>@sheglowug</span>
                </a>
              </li>
              <li>
                <a
                  href="https://tiktok.com/@sheglowug"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-3 text-gray-400 transition hover:text-white"
                >
                  <svg class="h-5 w-5 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z" />
                  </svg>
                  <span>@sheglowug</span>
                </a>
              </li>
              <li class="flex items-center gap-3 text-gray-400">
                <svg
                  class="h-5 w-5 flex-shrink-0"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M2.25 18.75a60.07 60.07 0 0115.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 013 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 00-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 01-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 003 15h-.75"
                  />
                </svg>
                <span>Kampala, Uganda</span>
              </li>
            </ul>
            <%!-- Social icon buttons --%>
            <div class="mt-8 flex gap-3">
              <a
                href="https://wa.me/256742013968"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="WhatsApp"
                class="flex h-10 w-10 items-center justify-center rounded-full border border-gray-700 text-gray-400 transition hover:border-green-500 hover:text-green-400"
              >
                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
                </svg>
              </a>
              <a
                href="https://instagram.com/sheglowug"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Instagram"
                class="flex h-10 w-10 items-center justify-center rounded-full border border-gray-700 text-gray-400 transition hover:border-pink-500 hover:text-pink-400"
              >
                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z" />
                </svg>
              </a>
              <a
                href="https://tiktok.com/@sheglowug"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="TikTok"
                class="flex h-10 w-10 items-center justify-center rounded-full border border-gray-700 text-gray-400 transition hover:border-white hover:text-white"
              >
                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z" />
                </svg>
              </a>
            </div>
          </div>

          <%!-- Quick Links --%>
          <div>
            <h3 class="text-xl font-semibold text-white">Quick Links</h3>
            <ul class="mt-6 space-y-3">
              <li>
                <a href="/" class="text-gray-400 transition hover:text-white">Home</a>
              </li>
              <li>
                <a href="/#collections" class="text-gray-400 transition hover:text-white">
                  Shop Categories
                </a>
              </li>
              <li>
                <a href="/#new-arrivals" class="text-gray-400 transition hover:text-white">
                  Fresh Drops
                </a>
              </li>
              <li>
                <a href="/#bestsellers" class="text-gray-400 transition hover:text-white">
                  Best Sellers
                </a>
              </li>
              <li>
                <a href="/#contact" class="text-gray-400 transition hover:text-white">
                  Contact Us
                </a>
              </li>
            </ul>
          </div>

          <%!-- Customer Care --%>
          <div>
            <h3 class="text-xl font-semibold text-white">Customer Care</h3>
            <ul class="mt-6 space-y-3">
              <li>
                <a href="/info/how-to-order" class="text-gray-400 transition hover:text-white">
                  🛍️ How to Order
                </a>
              </li>
              <li>
                <a href="/info/size-guide" class="text-gray-400 transition hover:text-white">
                  ✨ Skin Guide
                </a>
              </li>
              <li>
                <a href="/info/shipping-delivery" class="text-gray-400 transition hover:text-white">
                  🚚 Shipping &amp; Delivery
                </a>
              </li>
              <li>
                <a href="/info/returns-exchanges" class="text-gray-400 transition hover:text-white">
                  🔄 Returns &amp; Exchanges
                </a>
              </li>
              <li>
                <a
                  href="https://wa.me/256742013968?text=Hi%20SheGlow%20UG%2C%20I%27d%20love%20help%20choosing%20the%20right%20products%20for%20my%20skin."
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-gray-400 transition hover:text-white"
                >
                  💬 Talk to SheGlow
                </a>
              </li>
            </ul>
          </div>

          <%!-- Newsletter --%>
          <div>
            <h3 class="text-xl font-semibold text-white">Stay in the Loop</h3>
            <p class="mt-6 text-gray-400">
              Be the first to know about skincare restocks, glow bundles, and exclusive routine offers.
            </p>
            <form class="mt-6" phx-submit="subscribe_newsletter">
              <div class="relative">
                <input
                  type="email"
                  name="email"
                  placeholder="Enter Your Email"
                  required
                  class="w-full rounded-full border border-gray-700 bg-transparent py-3 pl-5 pr-14 text-white placeholder-gray-500 transition focus:border-white focus:outline-none focus:ring-0"
                />
                <button
                  type="submit"
                  class="absolute right-1.5 top-1/2 -translate-y-1/2 flex h-9 w-9 items-center justify-center rounded-full bg-[#C8001F] text-white transition hover:bg-[var(--brand-primary-dark)]"
                >
                  <svg
                    class="h-4 w-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    stroke-width="2"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M4.5 19.5l15-15m0 0H8.25m11.25 0v11.25"
                    />
                  </svg>
                </button>
              </div>
              <p class="mt-4 text-xs text-gray-500">
                Follow us on Instagram
                <a
                  href="https://instagram.com/sheglowug"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-[#C8001F] transition hover:underline"
                >
                  @sheglowug
                </a>
                for daily glow inspiration.
              </p>
            </form>
          </div>
        </div>
      </div>

      <%!-- Large Logo Marquee --%>
      <div class="overflow-hidden border-t border-gray-800">
        <div class="animate-marquee-slow flex whitespace-nowrap py-8">
          <span class="mx-8 text-[100px] font-bold text-gray-100 opacity-[0.06] sm:text-[140px] lg:text-[180px]">
            SheGlow UG
          </span>
          <span class="mx-8 text-[100px] font-bold text-gray-100 opacity-[0.06] sm:text-[140px] lg:text-[180px]">
            SheGlow UG
          </span>
          <span class="mx-8 text-[100px] font-bold text-gray-100 opacity-[0.06] sm:text-[140px] lg:text-[180px]">
            SheGlow UG
          </span>
          <span class="mx-8 text-[100px] font-bold text-gray-100 opacity-[0.06] sm:text-[140px] lg:text-[180px]">
            SheGlow UG
          </span>
        </div>
      </div>

      <%!-- Copyright --%>
      <div class="border-t border-gray-800 py-6 px-4">
        <div class="mx-auto flex max-w-7xl flex-col items-center gap-2 sm:flex-row sm:justify-between">
          <p class="text-sm text-gray-500">
            &copy; {Date.utc_today().year} SheGlow UG. All rights reserved.
          </p>
          <p class="text-sm text-gray-600">
            Designed by
            <a href="https://www.michaelmunavu.com" class="text-gray-400 transition hover:text-white">
              Michael Munavu
            </a>
            &middot; Powered by
            <a href="https://www.virgil.africa" class="text-gray-400 transition hover:text-white">
              Virgil Africa
            </a>
          </p>
        </div>
      </div>
    </footer>
    """
  end
end
