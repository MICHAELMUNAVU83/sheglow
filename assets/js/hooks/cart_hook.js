/**
 * CartHook — persistent element in the navbar.
 * Rules:
 *  • On /cart or /checkout — drawer never opens; cart icon navigates normally.
 *  • Elsewhere — drawer opens on add-to-cart & cart-icon click.
 *  • Drawer closes automatically on any LiveView navigation to /cart or /checkout.
 */
import Cart from "../cart.js";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function isCartOrCheckout() {
  return (
    window.location.pathname === "/cart" ||
    window.location.pathname === "/checkout"
  );
}

function formatPrice(n) {
  return Number(n || 0).toLocaleString("en-KE");
}

function drawerEl() {
  return document.getElementById("cart-drawer");
}
function backdropEl() {
  return document.getElementById("cart-drawer-backdrop");
}

// ─── Drawer open / close ─────────────────────────────────────────────────────

window.CartDrawer = {
  open() {
    if (isCartOrCheckout()) return; // never open on these pages
    renderDrawer();
    const drawer = drawerEl();
    const backdrop = backdropEl();
    if (!drawer) return;
    document.body.style.overflow = "hidden";
    backdrop.style.opacity = "1";
    backdrop.style.pointerEvents = "auto";
    drawer.style.transform = "translateX(0)";
  },
  close() {
    const drawer = drawerEl();
    const backdrop = backdropEl();
    if (!drawer) return;
    document.body.style.overflow = "";
    backdrop.style.opacity = "0";
    backdrop.style.pointerEvents = "none";
    drawer.style.transform = "translateX(100%)";
  },
  isOpen() {
    const drawer = drawerEl();
    return drawer && getComputedStyle(drawer).transform !== "matrix(1, 0, 0, 1, 0, 0)";
  },
};

// ─── Render drawer from localStorage ─────────────────────────────────────────

function renderDrawer() {
  const items = Cart.getItems();
  const emptyEl = document.getElementById("cart-drawer-empty");
  const listEl = document.getElementById("cart-drawer-list");
  const footerEl = document.getElementById("cart-drawer-footer");
  const countEl = document.getElementById("drawer-item-count");
  const totalEl = document.getElementById("drawer-total");

  if (!listEl) return;

  const totalItems = Cart.getTotalItems();
  const totalPrice = Cart.getTotalPrice();

  if (countEl) countEl.textContent = String(totalItems);
  if (totalEl) totalEl.textContent = formatPrice(totalPrice);

  if (items.length === 0) {
    emptyEl && (emptyEl.style.display = "flex");
    listEl.classList.add("hidden");
    footerEl && footerEl.classList.add("hidden");
    return;
  }

  emptyEl && (emptyEl.style.display = "none");
  listEl.classList.remove("hidden");
  footerEl && footerEl.classList.remove("hidden");

  listEl.innerHTML = items
    .map((item) => {
      const variantLabel = [item.color, item.size].filter(Boolean).join(" · ");
      const linePrice = (item.price || 0) * (item.quantity || 1);
      const imgHtml = item.image
        ? `<img src="${item.image}" alt="${escHtml(item.name)}" class="h-full w-full object-cover" />`
        : `<div class="flex h-full items-center justify-center text-2xl">👗</div>`;

      return `
        <div class="flex gap-3 rounded-xl border border-gray-100 bg-white p-3 shadow-sm">
          <div class="h-20 w-16 flex-shrink-0 overflow-hidden rounded-lg bg-gray-100">${imgHtml}</div>
          <div class="flex flex-1 flex-col justify-between min-w-0">
            <div class="flex items-start justify-between gap-1">
              <div class="min-w-0">
                <p class="truncate text-sm font-semibold text-gray-900">${escHtml(item.name)}</p>
                ${variantLabel ? `<p class="mt-0.5 text-xs text-gray-400">${escHtml(variantLabel)}</p>` : ""}
              </div>
              <button
                onclick="window._cartDrawerRemove('${item.key}')"
                class="flex-shrink-0 rounded-lg p-1 text-gray-300 transition hover:bg-red-50 hover:text-red-500"
                aria-label="Remove"
              >
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                </svg>
              </button>
            </div>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-1 rounded-full border border-gray-200 px-2 py-0.5 text-sm">
                <button onclick="window._cartDrawerQty('${item.key}', ${Math.max(1, (item.quantity || 1) - 1)})"
                  class="flex h-5 w-5 items-center justify-center rounded-full text-gray-500 hover:bg-gray-100 hover:text-black">−</button>
                <span class="w-5 text-center font-medium text-gray-800">${item.quantity || 1}</span>
                <button onclick="window._cartDrawerQty('${item.key}', ${(item.quantity || 1) + 1})"
                  class="flex h-5 w-5 items-center justify-center rounded-full text-gray-500 hover:bg-gray-100 hover:text-black">+</button>
              </div>
              <span class="text-sm font-semibold text-gray-900">KES ${formatPrice(linePrice)}</span>
            </div>
          </div>
        </div>
      `;
    })
    .join("");
}

function escHtml(str) {
  return String(str || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// Drawer interaction handlers (called from inline onclick)
window._cartDrawerRemove = (key) => {
  Cart.removeItem(key);
  renderDrawer();
  updateBadge();
};
window._cartDrawerQty = (key, qty) => {
  Cart.updateQuantity(key, qty);
  renderDrawer();
  updateBadge();
};

// ─── Badge ────────────────────────────────────────────────────────────────────

function updateBadge() {
  const count = Cart.getTotalItems();
  const badge = document.getElementById("cart-count-badge");
  if (badge) {
    badge.textContent = count > 99 ? "99+" : String(count);
    badge.style.display = count > 0 ? "flex" : "none";
  }
}

// ─── Hook ─────────────────────────────────────────────────────────────────────

const CartHook = {
  mounted() {
    updateBadge();

    // Close drawer immediately if we're already on a cart/checkout page
    if (isCartOrCheckout()) window.CartDrawer.close();

    // Server signals a new item was added → update localStorage + maybe open drawer
    this.handleEvent("add-to-cart", (item) => {
      Cart.addItem(item);
      updateBadge();
      if (!isCartOrCheckout()) {
        window.CartDrawer.open();
      }
    });

    // Server cleared cart (post-payment)
    this.handleEvent("clear-cart", () => {
      Cart.clear();
      updateBadge();
      window.CartDrawer.close();
    });

    // Keep badge + open drawer in sync on cart changes
    this.onCartUpdated = () => {
      updateBadge();
      const drawer = drawerEl();
      if (drawer && drawer.style.transform === "translateX(0px)") {
        renderDrawer();
      }
    };
    window.addEventListener("cart:updated", this.onCartUpdated);

    // Cross-tab sync
    this.onStorage = (e) => {
      if (e.key === "sheglow_cart") updateBadge();
    };
    window.addEventListener("storage", this.onStorage);

    // Navigate to cart page (used by bundle page "Add All" flow)
    this.handleEvent("navigate-to-cart", () => {
      window.location.href = "/cart";
    });

    // Close drawer when LiveView navigates to /cart or /checkout
    this.onNavigate = () => {
      if (isCartOrCheckout()) window.CartDrawer.close();
    };
    window.addEventListener("phx:navigate", this.onNavigate);
    window.addEventListener("phx:page-loading-stop", this.onNavigate);

    // Escape key closes drawer
    this.onKeydown = (e) => {
      if (e.key === "Escape") window.CartDrawer.close();
    };
    window.addEventListener("keydown", this.onKeydown);
  },

  destroyed() {
    window.removeEventListener("cart:updated", this.onCartUpdated);
    window.removeEventListener("storage", this.onStorage);
    window.removeEventListener("phx:navigate", this.onNavigate);
    window.removeEventListener("phx:page-loading-stop", this.onNavigate);
    window.removeEventListener("keydown", this.onKeydown);
  },
};

export default CartHook;
