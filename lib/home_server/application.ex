defmodule HomeServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HomeServer.Repo,
      # Start the Telemetry supervisor
      HomeServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HomeServer.PubSub},
      # Start the Endpoint (http/https)
      HomeServerWeb.Endpoint,
      # Start a worker by calling: HomeServer.Worker.start_link(arg)
      # {HomeServer.Worker, arg}
      {HomeServer.SensorMeasurementsBroadway, []},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HomeServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
