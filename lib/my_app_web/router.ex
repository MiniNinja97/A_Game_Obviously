defmodule MyAppWeb.Router do
  use MyAppWeb, :router
  import MyAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Root /
scope "/", MyAppWeb do
  pipe_through [:browser]

  live "/", HomeLive, :index
end

# scope "/", MyAppWeb do
#   pipe_through [:browser, :require_authenticated_user]

#   live_session :require_authenticated_user,
#     on_mount: [{MyAppWeb.UserAuth, :require_authenticated}] do
#       live "/menu", GameMenuLive
#   end
# end

  # OAuth
  scope "/auth", MyAppWeb do
    pipe_through :browser

    get "/:provider", OAuthController, :request
    get "/:provider/callback", OAuthController, :callback
  end

  # Authenticated users
 scope "/", MyAppWeb do
  pipe_through [:browser, :require_authenticated_user]

  live_session :require_authenticated_user,
    on_mount: [{MyAppWeb.UserAuth, :require_authenticated}] do
      live "/menu", GameMenuLive
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
  end

  post "/users/update-password", UserSessionController, :update_password
end

  # Registration / login routes
scope "/", MyAppWeb do
  pipe_through [:browser, :require_authenticated_user]

  live_session :redirect_if_user_is_authenticated,
    on_mount: [{MyAppWeb.UserAuth, :redirect_if_user_is_authenticated}] do
    live "/users/register", UserLive.Registration, :new
    live "/users/log-in", UserLive.Login, :new
    live "/users/log-in/:token", UserLive.Confirmation, :new
  end

  post "/users/log-in", UserSessionController, :create
end

  # Dev routes
  if Application.compile_env(:my_app, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
