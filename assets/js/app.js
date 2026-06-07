// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import SwiperNewArrivals from "./hooks/swiper_new_arrivals.js";
import SwiperRelatedProducts from "./hooks/swiper_related_products.js";
import SwiperHero from "./hooks/swiper_hero.js";
import SwiperContact from "./hooks/swiper_contact.js";
import VideoBannerReveal from "./hooks/video_banner_reveal.js";
import CountdownTimer from "./hooks/countdown_timer.js";
import HomeReveal from "./hooks/home_reveal.js";
import SyncColorPicker from "./hooks/sync_color.js";
import ChatScroll from "./hooks/chat_scroll.js";
import ChatPersist from "./hooks/chat_persist.js";
import CartHook from "./hooks/cart_hook.js";
import CartSync from "./hooks/cart_sync.js";
import ChartHook from "./hooks/chart_hook.js";
import AddBundleToCart from "./hooks/add_bundle_to_cart.js";
import AddSingleToCart from "./hooks/add_single_to_cart.js";
// Safe CSRF token (avoid throwing if meta tag is missing)
const csrfMeta = document.querySelector("meta[name='csrf-token']");
const csrfToken = csrfMeta ? csrfMeta.getAttribute("content") : "";

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    SwiperNewArrivals,
    SwiperRelatedProducts,
    SwiperHero,
    SwiperContact,
    VideoBannerReveal,
    CountdownTimer,
    SyncColorPicker,
    ChatScroll,
    ChatPersist,
    HomeReveal,
    CartHook,
    CartSync,
    ChartHook,
    AddBundleToCart,
    AddSingleToCart,
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", () => topbar.show(300));
window.addEventListener("phx:page-loading-stop", () => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// Auto-dismiss flash messages after 4 s (info) or 6 s (error)
window.addEventListener("flash:auto-dismiss", (e) => {
  const { id, kind } = e.detail;
  const delay = kind === "error" ? 6000 : 4000;
  setTimeout(() => {
    const el = document.getElementById(id);
    if (el) el.click();
  }, delay);
});

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
