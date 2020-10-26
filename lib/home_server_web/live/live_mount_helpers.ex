defmodule HomeServerWeb.LiveMountHelpers do
  import Phoenix.LiveView

  def assign_defaults(%{"user_token" => user_token} = _session, socket) do
    _socket = assign_new(socket, :current_user, fn -> HomeServer.Accounts.get_user_by_session_token(user_token) end)

    #if socket.assigns.current_user.confirmed_at do
      #socket
    #else
      #redirect(socket, to: "/users/log_in")
    #end
  end

  def assign_defaults(_session, socket) do
    redirect(socket, to: "/users/log_in")
  end

end
