import Config

# Path to the cache manifest for static files
config :my_app, MyAppWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  exclude: [
    hosts: ["localhost", "127.0.0.1"]
  ],
  server: true

# Configure Swoosh API Client (needed for production email adapters)
config :swoosh, api_client: Swoosh.ApiClient.Req
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Note: All runtime-specific configuration, like PORT, SECRET_KEY_BASE,
# and GitHub OAuth, is handled in runtime.exs
