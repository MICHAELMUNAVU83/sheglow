/**
 * Initializes Swiper on the New Arrivals carousel with external navigation.
 * Requires Swiper to be loaded (e.g. from CDN before this app script).
 */
const SwiperNewArrivals = {
  mounted() {
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
      console.warn("Swiper not loaded yet, retrying...");
      setTimeout(() => this.initSwiper(), 50);
      return;
    }

    const prevBtn = document.getElementById("new-arrivals-prev");
    const nextBtn = document.getElementById("new-arrivals-next");

    this.swiper = new window.Swiper(this.el, {
      slidesPerView: 1,
      spaceBetween: 24,
      speed: 400,
      navigation: {
        nextEl: nextBtn,
        prevEl: prevBtn,
      },
      breakpoints: {
        640: { slidesPerView: 2 },
        1024: { slidesPerView: 4 },
      },
      on: {
        init: (swiper) => {
          this.updateNavState(swiper, prevBtn, nextBtn);
        },
        slideChange: (swiper) => {
          this.updateNavState(swiper, prevBtn, nextBtn);
        },
        reachBeginning: (swiper) => {
          this.updateNavState(swiper, prevBtn, nextBtn);
        },
        reachEnd: (swiper) => {
          this.updateNavState(swiper, prevBtn, nextBtn);
        },
      },
    });
  },

  updateNavState(swiper, prevBtn, nextBtn) {
    if (prevBtn) {
      if (swiper.isBeginning) {
        prevBtn.classList.add("opacity-40", "cursor-not-allowed");
        prevBtn.classList.remove("hover:border-black", "hover:text-black");
      } else {
        prevBtn.classList.remove("opacity-40", "cursor-not-allowed");
        prevBtn.classList.add("hover:border-black", "hover:text-black");
      }
    }

    if (nextBtn) {
      if (swiper.isEnd) {
        nextBtn.classList.add("opacity-40", "cursor-not-allowed");
        nextBtn.classList.remove("hover:border-black", "hover:text-black");
      } else {
        nextBtn.classList.remove("opacity-40", "cursor-not-allowed");
        nextBtn.classList.add("hover:border-black", "hover:text-black");
      }
    }
  },
};

export default SwiperNewArrivals;
