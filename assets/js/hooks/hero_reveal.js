// hooks/hero_reveal.js
const HeroReveal = {
  mounted() {
    // These elements may not exist depending on viewport (mobile vs desktop)
    this.heroImage = document.getElementById("hero-image") ||
                     document.getElementById("hero-image-desktop");
    this.heroContent = this.el.querySelector(".hero-content");

    this.ticking = false;

    this.handleScroll = () => {
      if (!this.ticking) {
        requestAnimationFrame(() => {
          this.updateReveal();
          this.ticking = false;
        });
        this.ticking = true;
      }
    };

    window.addEventListener("scroll", this.handleScroll, { passive: true });
    this.updateReveal();
  },

  updateReveal() {
    const rect = this.el.getBoundingClientRect();
    const windowHeight = window.innerHeight;

    const revealStart = windowHeight * 0.8;
    const revealEnd = windowHeight * 0.2;

    let progress = 0;
    if (rect.top < revealStart) {
      progress = Math.min(
        (revealStart - rect.top) / (revealStart - revealEnd),
        1,
      );
    }

    const easedProgress = this.easeOutQuart(progress);

    // Desktop: animate the image panel
    if (this.heroImage) {
      if (progress > 0.3) {
        const imageProgress = Math.min((progress - 0.3) / 0.7, 1);
        const easedImageProgress = this.easeOutCubic(imageProgress);
        const scale = 1.05 - easedImageProgress * 0.05;
        this.heroImage.style.opacity = easedImageProgress;
        this.heroImage.style.transform = `scale(${scale})`;
      }
    }

    // Desktop: animate the text content
    if (this.heroContent) {
      if (progress > 0.5) {
        this.heroContent.style.opacity = "1";
        this.heroContent.style.transform = "translateY(0)";
      } else {
        this.heroContent.style.opacity = "0";
        this.heroContent.style.transform = "translateY(20px)";
      }
    }
  },

  easeOutQuart(t) {
    return 1 - Math.pow(1 - t, 4);
  },

  easeOutCubic(t) {
    return 1 - Math.pow(1 - t, 3);
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
  },
};

export default HeroReveal;
