const CART_KEY = "sheglow_cart";

const Cart = {
  getItems() {
    try {
      return JSON.parse(localStorage.getItem(CART_KEY) || "[]");
    } catch {
      return [];
    }
  },

  saveItems(items) {
    localStorage.setItem(CART_KEY, JSON.stringify(items));
    window.dispatchEvent(new CustomEvent("cart:updated", { detail: { items } }));
  },

  // item shape: { id, slug, name, image, price, color, color_id, size, quantity }
  addItem(item) {
    const items = this.getItems();
    const key = `${item.id}__${item.color_id || ""}__${item.size || ""}`;
    const existing = items.find((i) => i.key === key);
    if (existing) {
      existing.quantity += item.quantity || 1;
    } else {
      items.push({ ...item, key, quantity: item.quantity || 1 });
    }
    this.saveItems(items);
    return items;
  },

  removeItem(key) {
    const items = this.getItems().filter((i) => i.key !== key);
    this.saveItems(items);
    return items;
  },

  updateQuantity(key, quantity) {
    const items = this.getItems().map((i) =>
      i.key === key ? { ...i, quantity: Math.max(1, quantity) } : i
    );
    this.saveItems(items);
    return items;
  },

  clear() {
    this.saveItems([]);
    return [];
  },

  getTotalItems() {
    return this.getItems().reduce((sum, i) => sum + (i.quantity || 1), 0);
  },

  getTotalPrice() {
    return this.getItems().reduce(
      (sum, i) => sum + (i.price || 0) * (i.quantity || 1),
      0
    );
  },
};

export default Cart;
