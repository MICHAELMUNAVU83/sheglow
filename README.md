# SheGlow UG

A full-featured e-commerce platform for SheGlow UG — a Kenyan fashion brand offering everyday luxury clothing. Built with [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) and [Ecto](https://hexdocs.pm/ecto).

---

## Tech Stack

| Layer        | Technology                                       |
| ------------ | ------------------------------------------------ |
| Framework    | [Phoenix](https://phoenixframework.org) (Elixir) |
| UI           | Phoenix LiveView + Tailwind CSS                  |
| Database     | PostgreSQL via Ecto                              |
| Payments     | Paystack                                         |
| Email        | Nexus API (custom branded HTML)                  |
| File Uploads | Local filesystem (`priv/static/uploads`)         |

---

## Getting Started

### Prerequisites

- Elixir ≥ 1.15
- Erlang/OTP ≥ 26
- PostgreSQL
- Node.js (for asset compilation)

### Setup

```bash
# Install dependencies and set up the database
mix setup

# Seed the database with collections, products, bundles, and info pages
mix run priv/repo/seeds.exs

# Seed the initial admin user (super_admin)
mix run priv/repo/seeds_admin.exs

# Start the dev server
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000) for the storefront and [http://localhost:4000/admin](http://localhost:4000/admin) for the admin panel.

---

## Environment Configuration

Key values can be overridden at runtime via environment variables:

| Variable              | Default                 | Purpose                              |
| --------------------- | ----------------------- | ------------------------------------ |
| `DATABASE_URL`        | (set in `dev.exs`)      | PostgreSQL connection string         |
| `SECRET_KEY_BASE`     | (generated)             | Phoenix secret key                   |
| `PHX_HOST`            | `example.com`           | Production hostname                  |
| `SITE_URL`            | `https://sheglowug.com` | Absolute base URL for emails & links |
| `ADMIN_EMAIL`         | `admin@gmail.com`       | Recipient for admin order alerts     |
| `PAYSTACK_SECRET_KEY` | —                       | Paystack secret key (server-side)    |
| `PAYSTACK_PUBLIC_KEY` | —                       | Paystack public key (client-side)    |
| `NEXUS_API_KEY`       | —                       | Nexus transactional email API key    |

Set these in `config/runtime.exs` for production or export them as shell variables.

---

## Admin Panel

Log in at `/users/log_in` with your admin credentials. Public registration is disabled — new team members are invited from **Admin → Team**.

Default seed credentials (change after first login):

| Email                 | Password     | Role        |
| --------------------- | ------------ | ----------- |
| michael@sheglow.co.ke | Sheglow2026! | super_admin |

See [Admin Help](/admin/help) inside the panel for a full guide to every section.

---

## Project Structure

```
lib/
├── sheglow/                    # Business logic & contexts
│   ├── accounts/              # Users, auth tokens, notifiers
│   ├── collections/           # Collection schema & context
│   ├── products/              # Product, variant, image schemas
│   ├── orders/                # Order schema & context
│   ├── bundles/               # Bundle & bundle-item schemas
│   ├── info_pages/            # Static info page schema & context
│   ├── promotions/            # Promo code schema & context
│   ├── app_config.ex          # Runtime config helpers (site_url, admin_email)
│   ├── gmail.ex               # Branded HTML email engine (Nexus API)
│   ├── order_notifier.ex      # Order confirmation & admin alert emails
│   └── paystack.ex            # Paystack payment verification
│
├── sheglow_web/                # Web layer
│   ├── components/
│   │   ├── home_components.ex   # Public storefront components (navbar, hero, etc.)
│   │   ├── sidebar_components.ex # Admin sidebar & nav
│   │   └── layouts/             # Root, app, and admin HTML layouts
│   ├── live/                    # All LiveView modules (public + admin)
│   └── router.ex                # All routes
│
priv/
├── repo/
│   ├── migrations/            # Database migrations
│   ├── seeds.exs              # Product/collection/bundle seed data
│   └── seeds_admin.exs        # Initial admin user seed
└── static/
    └── uploads/               # User-uploaded product images
```

---

## Key Features

- **Storefront** — Hero, collections grid, new arrivals, bundle deals, testimonials, countdown banner, contact section
- **Product pages** — Image gallery, size/color variant picker, size guide, shipping & returns info
- **Cart & Checkout** — Persistent cart (localStorage), Paystack inline payment, order confirmation
- **Order emails** — Branded HTML confirmation to customer + admin notification on every order
- **Admin Panel** — Dashboard, orders, products, collections, bundles, promotions, customers, team management, info pages
- **Auth** — Role-based access (`super_admin`, `admin`, `member`), admin-only registration, last-signed-in tracking
- **Info Pages** — DB-backed static pages (`/info/:slug`) editable from the admin panel

---

## Deployment

```bash
# Build assets
mix assets.deploy

# Run migrations
mix ecto.migrate

# Start with production config
PHX_HOST=sheglowug.com \
SITE_URL=https://sheglowug.com \
SECRET_KEY_BASE=<generated> \
DATABASE_URL=<postgres-url> \
mix phx.server
```
