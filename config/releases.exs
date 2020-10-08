# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :home_server, HomeServer.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :home_server, HomeServerWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base


sensor_measurements_queue = System.fetch_env!("SENSOR_MEASUREMENTS_QUEUE")
amqp_connection_options = [
  host:     System.fetch_env!("RABBIT_MQ_HOST"),
  username: System.fetch_env!("RABBIT_MQ_USERNAME"),
  password: System.fetch_env!("RABBIT_MQ_PASSWORD")
]

config :amqp, :sensor_measurements_queue, sensor_measurements_queue
config :amqp, :connection_options, amqp_connection_options
config :broadway, :producer_module, {
  BroadwayRabbitMQ.Producer,
  queue: sensor_measurements_queue,
  connection: amqp_connection_options,
  qos: [ prefetch_count: 50 ]
}

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :home_server, HomeServerWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
