import Config

# Enable the server if PHX_SERVER=true is set
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
  # Secret key base for signing/encrypting cookies
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # Hostname for URL generation
  host = System.get_env("PHX_HOST") || "example.com"

  config :my_app, MyAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"], # HTTPS URL
    secret_key_base: secret_key_base

  # GitHub OAuth
  config :ueberauth, Ueberauth.Strategy.Github,
    client_id: System.get_env("GITHUB_CLIENT_ID"),
    client_secret: System.get_env("GITHUB_CLIENT_SECRET")

  # DATABASE_URL parsing
  database_url = System.get_env("DATABASE_URL") ||
    raise "DATABASE_URL is missing!"

  %URI{userinfo: userinfo, host: db_host, port: db_port, path: "/" <> db_name} = URI.parse(database_url)
  [db_user, db_pass] = String.split(userinfo, ":")

  config :my_app, MyApp.Repo,
    username: db_user,
    password: db_pass,
    hostname: db_host,
    database: db_name,
    port: db_port,
    pool_size: 10,
    show_sensitive_data_on_connection_error: true
end
