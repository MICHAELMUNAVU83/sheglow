// hooks/video_banner_reveal.js
const VideoBannerReveal = {
  mounted() {
    this.video = document.getElementById("hero-video");
    this.revealContainer = document.getElementById("video-reveal-container");
    this.toggleButton = document.getElementById("video-toggle");
    this.playIcon = document.getElementById("play-icon");
    this.pauseIcon = document.getElementById("pause-icon");

    this.isRevealed = false;
    this.isPlaying = false;
    this.ticking = false;

    this.setupScrollReveal();
    this.setupToggleButton();
  },

  setupScrollReveal() {
    // Use scroll event for smoother, more controlled animation
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

    // Initial check
    this.updateReveal();
  },

  updateReveal() {
    const rect = this.el.getBoundingClientRect();
    const windowHeight = window.innerHeight;

    // ============================================
    // ADJUST THESE VALUES TO CONTROL REVEAL SPEED
    // ============================================

    // How many pixels of scroll the reveal should take (larger = slower, more gradual)
    const revealDistance = 1400;

    // When to start the reveal (pixels from bottom of viewport)
    const startOffset = 200;

    // ============================================

    // Calculate how far into the viewport the element is
    const elementTop = rect.top;
    const triggerPoint = windowHeight - startOffset;

    // Calculate progress (0 to 1)
    let progress = 0;

    if (elementTop < triggerPoint) {
      // Element has entered the trigger zone
      const scrolledPast = triggerPoint - elementTop;
      progress = Math.min(scrolledPast / revealDistance, 1);
    }

    // Apply easing for even smoother animation
    const easedProgress = this.easeOutQuart(progress);

    // Map progress to clip-path circle size (0% to 150%)
    const circleSize = easedProgress * 150;

    // Apply with CSS transition for extra smoothness
    this.revealContainer.style.clipPath = `circle(${circleSize}% at 50% 50%)`;

    // Start video when fully revealed
    if (progress >= 1 && !this.isRevealed) {
      this.isRevealed = true;
      this.playVideo();
    }

    // Pause video when scrolling back up
    if (progress < 0.2 && this.isRevealed) {
      this.isRevealed = false;
      this.pauseVideo();
    }
  },

  // Smoother easing function
  easeOutQuart(t) {
    return 1 - Math.pow(1 - t, 4);
  },

  // Alternative easing options:
  // easeOutCubic(t) { return 1 - Math.pow(1 - t, 3); }
  // easeOutQuint(t) { return 1 - Math.pow(1 - t, 5); }
  // easeInOutCubic(t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }

  setupToggleButton() {
    if (this.toggleButton) {
      this.toggleButton.addEventListener("click", () => {
        if (this.isPlaying) {
          this.pauseVideo();
        } else {
          this.playVideo();
        }
      });
    }
  },

  playVideo() {
    if (this.video) {
      this.video
        .play()
        .then(() => {
          this.isPlaying = true;
          this.updateButtonState();
        })
        .catch((error) => {
          console.log("Video play failed:", error);
        });
    }
  },

  pauseVideo() {
    if (this.video) {
      this.video.pause();
      this.isPlaying = false;
      this.updateButtonState();
    }
  },

  updateButtonState() {
    if (this.playIcon && this.pauseIcon) {
      if (this.isPlaying) {
        this.playIcon.classList.add("hidden");
        this.pauseIcon.classList.remove("hidden");
      } else {
        this.playIcon.classList.remove("hidden");
        this.pauseIcon.classList.add("hidden");
      }
    }
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
    if (this.video) {
      this.video.pause();
    }
  },
};

export default VideoBannerReveal;
