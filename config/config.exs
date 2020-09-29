# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :e_ver_api,
  ecto_repos: [EVerApi.Repo]

# Configures the endpoint
config :e_ver_api, EVerApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ae4EIBFrXLBrskGLns6j0k8dlo+L1B3N1Tu5MHYYLKsfXNuTYv/9hcyym1XDOGPr",
  render_errors: [view: EVerApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: EVerApi.PubSub,
  live_view: [signing_salt: "nemG+wfc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :e_ver_api, EVerApi.Guardian,
  issuer: "e_ver_api",
  secret_key: System.get_env("JWT_SECRET") # mix guardian.gen.secret

config :e_ver_api, EVerApi.AuthAccessPipeline,
  module: EVerApi.Guardian,
  error_handler: EVerApi.AuthErrorHandler
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
