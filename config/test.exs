use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :e_ver_api, EVerApi.Repo,
  username: System.get_env("DB_USERNAME_TEST"),
  password: System.get_env("DB_PASSWORD_TEST"),
  database: System.get_env("DB_DATABASE_TEST"),
  hostname: System.get_env("DB_HOSTNAME_TEST"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :e_ver_api, EVerApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :arc, storage: Arc.Storage.Local
