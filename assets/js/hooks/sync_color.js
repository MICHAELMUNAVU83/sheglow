const SyncColorPicker = {
  mounted() {
    const swatch = this.el.querySelector("input[type='color']");
    const text = this.el.querySelector("input[type='text']");

    if (!swatch || !text) return;

    swatch.addEventListener("input", (e) => {
      text.value = e.target.value;
      text.dispatchEvent(new Event("change", { bubbles: true }));
    });

    // Also sync text → swatch when user types a valid hex
    text.addEventListener("input", (e) => {
      const val = e.target.value.trim();
      if (/^#[0-9a-fA-F]{6}$/.test(val)) {
        swatch.value = val;
      }
    });
  },
};

export default SyncColorPicker;
