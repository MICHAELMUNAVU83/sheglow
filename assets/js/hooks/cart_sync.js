/**
 * CartSync — attached to the cart and checkout pages.
 * On mount it reads localStorage and sends items to the LiveView.
 * Also handles item remove and quantity changes from the server.
 */
import Cart from "../cart.js";

const CartSync = {
  mounted() {
    // Send cart to LiveView immediately on mount
    this.pushEvent("cart_loaded", { items: Cart.getItems() });

    // Handle item removal triggered from LiveView
    this.handleEvent("remove-cart-item", ({ key }) => {
      Cart.removeItem(key);
      this.pushEvent("cart_loaded", { items: Cart.getItems() });
    });

    // Handle quantity update triggered from LiveView
    this.handleEvent("update-cart-quantity", ({ key, quantity }) => {
      Cart.updateQuantity(key, quantity);
      this.pushEvent("cart_loaded", { items: Cart.getItems() });
    });

    // Swap a cart item's variant (color / size) keeping name, image, price intact
    // Updates in-place so the item order never changes
    this.handleEvent("swap-cart-item", ({ old_key, color, color_id, color_hex, size }) => {
      const items = Cart.getItems();
      const idx = items.findIndex((i) => i.key === old_key);
      if (idx === -1) return;

      const existing = items[idx];
      const new_key = `${existing.id}__${color_id || existing.color_id || ""}__${size || existing.size || ""}`;

      items[idx] = {
        ...existing,
        key: new_key,
        color: color || existing.color,
        color_id: color_id || existing.color_id,
        color_hex: color_hex || existing.color_hex,
        size: size || existing.size,
      };

      Cart.saveItems(items);
      this.pushEvent("cart_loaded", { items: Cart.getItems() });
    });

    // Clear cart when server confirms successful order
    this.handleEvent("clear-cart", () => {
      Cart.clear();
    });
  },
};

export default CartSync;
