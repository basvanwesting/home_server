defmodule HomeServerWeb.DeviceLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.UserDevices

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:device, get_device!(id, socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Device"
  defp page_title(:edit), do: "Edit Device"

  defp get_device!(id, user) do
    UserDevices.get_device!(id, user)
    |> HomeServer.Repo.preload(:location)
  end
end
