defmodule SheglowWeb.Router do
  use SheglowWeb, :router

  import SheglowWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SheglowWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SheglowWeb do
    pipe_through :browser

    live "/", HomeLive.Index, :index
    live "/collections", CollectionsLive.Index, :index
    live "/collections/:slug", CategoryLive.Index, :index
    live "/products/:slug", OldProductLive.Index, :index
    live "/cart", CartLive.Index, :index
    live "/checkout", CheckoutLive.Index, :index
    live "/success", SuccessLive.Index, :index
    live "/info/:slug", InfoLive.Show, :show
    live "/bundles/:id", BundleShowLive.Index, :index

    live_session :admin,
      on_mount: [{SheglowWeb.UserAuth, :require_admin}] do
      scope "/admin" do
        live "/", DashboardLive.Index, :index

        live "/orders", OrderLive.Index, :index
        live "/orders/:id", OrderLive.Show, :show

        live "/customers", CustomerLive.Index, :index
        live "/customers/:id", CustomerLive.Show, :show

        live "/products", ProductLive.Index, :index
        live "/products/new", ProductLive.Index, :new
        live "/products/:id/edit", ProductLive.Index, :edit

        live "/products/:id", ProductLive.Show, :show
        live "/products/:id/show/edit", ProductLive.Show, :edit
        live "/collections", CollectionLive.Index, :index
        live "/collections/new", CollectionLive.Index, :new
        live "/collections/:id/edit", CollectionLive.Index, :edit

        live "/collections/:id", CollectionLive.Show, :show
        live "/collections/:id/show/edit", CollectionLive.Show, :edit

        live "/product_variants", ProductVariantLive.Index, :index
        live "/product_variants/new", ProductVariantLive.Index, :new
        live "/product_variants/:id/edit", ProductVariantLive.Index, :edit

        live "/product_variants/:id", ProductVariantLive.Show, :show
        live "/product_variants/:id/show/edit", ProductVariantLive.Show, :edit

        live "/product_images", ProductImageLive.Index, :index
        live "/product_images/new", ProductImageLive.Index, :new
        live "/product_images/:id/edit", ProductImageLive.Index, :edit

        live "/product_images/:id", ProductImageLive.Show, :show
        live "/product_images/:id/show/edit", ProductImageLive.Show, :edit

        live "/bundles", BundleLive.Index, :index
        live "/bundles/new", BundleLive.Index, :new
        live "/bundles/:id/edit", BundleLive.Index, :edit

        live "/bundles/:id", BundleLive.Show, :show
        live "/bundles/:id/show/edit", BundleLive.Show, :edit

        live "/bundle_items", BundleItemLive.Index, :index
        live "/bundle_items/new", BundleItemLive.Index, :new
        live "/bundle_items/:id/edit", BundleItemLive.Index, :edit

        live "/bundle_items/:id", BundleItemLive.Show, :show
        live "/bundle_items/:id/show/edit", BundleItemLive.Show, :edit

        live "/testimonials", TestimonialLive.Index, :index
        live "/testimonials/new", TestimonialLive.Index, :new
        live "/testimonials/:id/edit", TestimonialLive.Index, :edit

        live "/testimonials/:id", TestimonialLive.Show, :show
        live "/testimonials/:id/show/edit", TestimonialLive.Show, :edit

        live "/promotions", PromotionLive.Index, :index

        live "/pages", AdminPageLive.Index, :index
        live "/pages/:id/edit", AdminPageLive.Index, :edit

        live "/team", TeamLive.Index, :index

        live "/chat", AdminChatLive.Index, :index
        live "/chat/:id", AdminChatLive.Show, :show

        live "/help", HelpLive.Index, :index

        live "/theme", ThemeLive.Index, :index
        live "/settings", AdminPageLive.Index, :index
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SheglowWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sheglow, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SheglowWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SheglowWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SheglowWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SheglowWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SheglowWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", SheglowWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SheglowWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
