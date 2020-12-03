# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :wisps, WispsWeb.Endpoint,
  url: [host: "wisps.underjord.io"],
  http: [
    port: 8600
  ],
  https: [
    port: 8601,
    cipher_suite: :strong,
    #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
    #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: "+o9kQn5VX6vc7xSw6XFOJmT6k8iolvHrDjVzUPGWEjA3gn+nHbWXlObxVVp4ce1D",
  render_errors: [view: WispsWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Wisps.PubSub,
  live_view: [signing_salt: "qXZJB9l0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
