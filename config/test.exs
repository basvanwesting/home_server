import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :home_server, HomeServer.Repo,
  username: "postgres",
  password: "example",
  database: "home_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :home_server, HomeServerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :amqp, :sensor_measurements_queue, "sensor_measurements_test"

config :amqp, :connection_options,
  host: "localhost",
  port: 5672,
  username: "guest",
  password: "guest"

config :broadway, :producer_module, {Broadway.DummyProducer, []}
