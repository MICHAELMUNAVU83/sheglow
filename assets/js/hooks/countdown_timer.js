const CountdownTimer = {
  mounted() {
    // Always 2 hours from the moment the page loads
    this.endDate = new Date(Date.now() + 2 * 60 * 60 * 1000);

    this.hoursEl = document.getElementById("countdown-hours");
    this.minutesEl = document.getElementById("countdown-minutes");
    this.secondsEl = document.getElementById("countdown-seconds");

    this.updateCountdown();
    this.interval = setInterval(() => this.updateCountdown(), 1000);
  },

  updateCountdown() {
    const diff = this.endDate - Date.now();

    if (diff <= 0) {
      clearInterval(this.interval);
      this.hoursEl.textContent = "00";
      this.minutesEl.textContent = "00";
      this.secondsEl.textContent = "00";
      return;
    }

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);

    this.hoursEl.textContent = hours.toString().padStart(2, "0");
    this.minutesEl.textContent = minutes.toString().padStart(2, "0");
    this.secondsEl.textContent = seconds.toString().padStart(2, "0");
  },

  destroyed() {
    if (this.interval) {
      clearInterval(this.interval);
    }
  },
};

export default CountdownTimer;
