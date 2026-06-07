/**
 * Generic Chart.js hook for Phoenix LiveView.
 *
 * Usage in HEEx:
 *   <canvas id="my-chart" phx-hook="ChartHook"
 *           data-type="line"
 *           data-chart={Jason.encode!(%{labels: [...], datasets: [...]})} />
 *
 * The hook reads `data-type` and `data-chart` on mount.
 * When the server pushes "update_chart" with new payload, it patches the chart.
 */
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

const ChartHook = {
  mounted() {
    this.renderChart();

    this.handleEvent("update_chart", ({ id, data }) => {
      if (id !== this.el.id) return;
      this.updateChart(data);
    });
  },

  updated() {
    // Re-render if data-chart attribute changed via LiveView patch
    const newJson = this.el.dataset.chart;
    if (newJson && newJson !== this._lastJson) {
      this.updateChart(JSON.parse(newJson));
    }
  },

  destroyed() {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },

  renderChart() {
    const type = this.el.dataset.type || "line";
    const raw  = this.el.dataset.chart;
    if (!raw) return;

    try {
      const config   = JSON.parse(raw);
      this._lastJson = raw;

      if (this.chart) this.chart.destroy();

      // Merge server options with live JS callbacks (JSON can't hold functions)
      const opts = config.options
        ? deepMergeCallbacks(type, config.options)
        : defaultOptions(type);

      this.chart = new Chart(this.el, {
        type,
        data: config.data || config,
        options: opts,
      });
    } catch (e) {
      console.error("[ChartHook] parse error", e);
    }
  },

  updateChart(config) {
    if (!this.chart) {
      this.renderChart();
      return;
    }
    const incoming = typeof config === "string" ? JSON.parse(config) : config;
    const data = incoming.data || incoming;

    this.chart.data.labels = data.labels;
    data.datasets.forEach((ds, i) => {
      if (this.chart.data.datasets[i]) {
        this.chart.data.datasets[i].data = ds.data;
      }
    });
    this.chart.update("active");
  },
};

/** Apply live JS callbacks/formatters to server-provided options */
function deepMergeCallbacks(type, opts) {
  const kshFmt = (v) => `KES ${Number(v).toLocaleString()}`;

  // Always inject responsive + maintainAspectRatio
  opts.responsive           = true;
  opts.maintainAspectRatio  = false;

  // Tooltip callback
  opts.plugins = opts.plugins || {};
  opts.plugins.tooltip = opts.plugins.tooltip || {};
  opts.plugins.tooltip.callbacks = {
    label: (ctx) => {
      const val = ctx.parsed?.y ?? ctx.parsed?.x ?? ctx.raw;
      return typeof val === "number" ? ` ${kshFmt(val)}` : ` ${val}`;
    },
  };

  // Axis tick formatters
  if (opts.scales) {
    if (type === "line" && opts.scales.y) {
      opts.scales.y.ticks = opts.scales.y.ticks || {};
      opts.scales.y.ticks.callback = (v) =>
        v >= 1000 ? `KES ${(v / 1000).toFixed(0)}k` : `KES ${v}`;
    }
    if (type === "bar" && opts.scales.x) {
      opts.scales.x.ticks = opts.scales.x.ticks || {};
      opts.scales.x.ticks.callback = (v) =>
        v >= 1000 ? `KES ${(v / 1000).toFixed(0)}k` : `KES ${v}`;
    }
  }

  return opts;
}

function defaultOptions(type) {
  const base = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: type !== "line" && type !== "bar",
        position: "bottom",
        labels: {
          boxWidth: 10,
          padding: 16,
          font: { size: 12 },
        },
      },
      tooltip: {
        callbacks: {
          label: (ctx) => {
            const val = ctx.parsed.y ?? ctx.parsed;
            return typeof val === "number"
              ? ` KES ${val.toLocaleString()}`
              : ` ${val}`;
          },
        },
      },
    },
  };

  if (type === "line") {
    return {
      ...base,
      scales: {
        x: {
          grid: { display: false },
          ticks: { font: { size: 11 }, color: "#9ca3af", maxTicksLimit: 8 },
        },
        y: {
          grid: { color: "#f3f4f6" },
          ticks: {
            font: { size: 11 },
            color: "#9ca3af",
            callback: (v) => `KES ${(v / 1000).toFixed(0)}k`,
          },
          beginAtZero: true,
        },
      },
    };
  }

  if (type === "bar") {
    return {
      ...base,
      indexAxis: "y",
      scales: {
        x: {
          grid: { color: "#f3f4f6" },
          ticks: {
            font: { size: 11 },
            color: "#9ca3af",
            callback: (v) => `KES ${(v / 1000).toFixed(0)}k`,
          },
          beginAtZero: true,
        },
        y: {
          grid: { display: false },
          ticks: { font: { size: 11 }, color: "#374151" },
        },
      },
    };
  }

  return base;
}

export default ChartHook;
