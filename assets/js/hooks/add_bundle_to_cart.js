import Cart from "../cart.js";

function updateBadge() {
  const count = Cart.getTotalItems();
  const badge = document.getElementById("cart-count-badge");
  if (badge) {
    badge.textContent = count > 99 ? "99+" : String(count);
    badge.style.display = count > 0 ? "flex" : "none";
  }
}

// Adds every product in a bundle to cart in one click
const AddBundleToCart = {
  mounted() {
    this.el.addEventListener("click", () => {
      try {
        const products = JSON.parse(this.el.dataset.products || "[]");
        products.forEach((p) => Cart.addItem({ ...p, quantity: 1 }));
        updateBadge();
        window.location.href = "/cart";
      } catch (e) {
        console.error("AddBundleToCart error", e);
      }
    });
  },
};

export default AddBundleToCart;
