defmodule HomeServerWeb.LiveMountHelpers do
  import Phoenix.LiveView

  def assign_defaults(%{"user_token" => user_token} = _session, socket) do
    socket
    |> assign_new(:current_user, fn ->
      HomeServer.Accounts.get_user_by_session_token(user_token)
    end)
    |> assign(:timezone, "Europe/Amsterdam")
  end

  def assign_defaults(_session, socket) do
    redirect(socket, to: "/users/log_in")
  end
end
