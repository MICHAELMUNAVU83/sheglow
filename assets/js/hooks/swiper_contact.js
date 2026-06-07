/**
 * Auto-playing Swiper for the contact section right-side image panel.
 * Slides through active product images automatically.
 */
const SwiperContact = {
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
      speed: 1200,
      autoplay: {
        delay: 4000,
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

export default SwiperContact;
