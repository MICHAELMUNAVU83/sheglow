/**
 * Auto-playing Swiper for the hero right-side image panel.
 * Uses a fade effect so transitions feel smooth and cinematic.
 * The containing div keeps id="hero-image" so HeroReveal can still
 * animate opacity/transform on the entire panel.
 */
const SwiperHero = {
  mounted() {
    this.retries = 0;
    this.initSwiper();
  },

  destroyed() {
    if (this.swiper) {
      this.swiper.destroy(true, true);
      this.swiper = null;
    }
  },

  initSwiper() {
    if (typeof window.Swiper === "undefined") {
      if (this.retries < 40) {
        this.retries++;
        setTimeout(() => this.initSwiper(), 100);
      }
      return;
    }

    const slides = this.el.querySelectorAll(".swiper-slide");
    if (slides.length === 0) return;

    this.swiper = new window.Swiper(this.el, {
      effect: "fade",
      fadeEffect: { crossFade: true },
      slidesPerView: 1,
      loop: slides.length > 1,
      speed: 1000,
      autoplay: {
        delay: 3500,
        disableOnInteraction: false,
        pauseOnMouseEnter: true,
        enabled: true,
      },
      allowTouchMove: true,
    });

    if (slides.length > 1) {
      this.swiper.autoplay.start();
    }
  },
};

export default SwiperHero;
