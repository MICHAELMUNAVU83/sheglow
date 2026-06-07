import Cart from "../cart.js";

function updateBadge() {
  const count = Cart.getTotalItems();
  const badge = document.getElementById("cart-count-badge");
  if (badge) {
    badge.textContent = count > 99 ? "99+" : String(count);
    badge.style.display = count > 0 ? "flex" : "none";
  }
}

// Adds a single product to cart and shows a brief confirmation on the button
const AddSingleToCart = {
  mounted() {
    this.el.addEventListener("click", () => {
      try {
        const product = JSON.parse(this.el.dataset.product || "{}");
        Cart.addItem({ ...product, quantity: 1 });
        updateBadge();

        const original = this.el.textContent;
        this.el.textContent = "Added ✓";
        this.el.disabled = true;
        setTimeout(() => {
          this.el.textContent = original;
          this.el.disabled = false;
        }, 1500);
      } catch (e) {
        console.error("AddSingleToCart error", e);
      }
    });
  },
};

export default AddSingleToCart;
