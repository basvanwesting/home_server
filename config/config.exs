# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :home_server,
  ecto_repos: [HomeServer.Repo]

# Configures the endpoint
config :home_server, HomeServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NYAedjQ/aCvEIoBA67WNRQFrX/QxRnA0BP6N0QC0uvE62qnLvCi/QL7gpcGwGSnO",
  render_errors: [view: HomeServerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HomeServer.PubSub,
  live_view: [signing_salt: "9yO6q4Am"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
