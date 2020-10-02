defmodule HomeServer.Repo do
  use Ecto.Repo,
    otp_app: :home_server,
    adapter: Ecto.Adapters.Postgres
end
