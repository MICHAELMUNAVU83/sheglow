/**
 * Reveal elements on scroll: add .in-view when in viewport, CSS handles the transition.
 * Add data-motion-reveal to any element. Optional: data-motion-delay, data-motion-direction, data-motion-stagger-group (on parent).
 */
const HomeReveal = {
  mounted() {
    this.revealTargets = this.el.querySelectorAll("[data-motion-reveal]");
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          const el = entry.target;
          if (el.dataset.motionDone === "true") return;
          el.dataset.motionDone = "true";
          this.reveal(el);
        });
      },
      { rootMargin: "0px 0px -6% 0px", threshold: 0 }
    );
    this.revealTargets.forEach((el) => this.observer.observe(el));
  },

  reveal(el) {
    let delayMs = (Number(el.dataset.motionDelay) || 0) * 1000;
    const staggerGroup = el.closest("[data-motion-stagger-group]");
    if (staggerGroup) {
      const step = (Number(staggerGroup.dataset.motionStaggerGroup) || 0.08) * 1000;
      const siblings = [...staggerGroup.querySelectorAll("[data-motion-reveal]")];
      const index = siblings.indexOf(el);
      if (index >= 0) delayMs += index * step;
    }
    const direction = (el.dataset.motionDirection || "up").toLowerCase();
    el.dataset.motionDirection = direction;
    if (delayMs > 0) {
      el.style.transitionDelay = `${delayMs}ms`;
    }
    requestAnimationFrame(() => {
      el.classList.add("in-view");
    });
  },

  destroyed() {
    if (this.observer && this.revealTargets) {
      this.revealTargets.forEach((el) => {
        try {
          this.observer.unobserve(el);
        } catch (_) {}
      });
    }
  },
};

export default HomeReveal;
