import Config

# Enable server if PHX_SERVER=true
if System.get_env("PHX_SERVER") do
  config :my_app, MyAppWeb.Endpoint, server: true
end

# Get port from environment or default to 4000
port = String.to_integer(System.get_env("PORT") || "4000")

config :my_app, MyAppWeb.Endpoint,
  http: [
    ip: {0, 0, 0, 0},  # Bind to all interfaces
    port: port
  ],
  server: true

if config_env() == :prod do
  # Secret key base
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one with: mix phx.gen.secret
      """

  # Hostname for URL generation (https)
  host = System.get_env("PHX_HOST") || "example.com"

  # Configure endpoint URL
  config :my_app, MyAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0}, # Bind all interfaces, IPv6 compatible
      port: port
    ],
    secret_key_base: secret_key_base

  # Database configuration using Railway's internal MYSQL_URL
  database_url =
    System.get_env("MYSQL_URL") ||
      raise """
      environment variable MYSQL_URL is missing
      """

  config :my_app, MyApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    show_sensitive_data_on_connection_error: true

  # GitHub OAuth
  config :ueberauth, Ueberauth.Strategy.Github,
    client_id: System.get_env("GITHUB_CLIENT_ID"),
    client_secret: System.get_env("GITHUB_CLIENT_SECRET")
end
