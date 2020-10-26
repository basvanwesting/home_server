defmodule HomeServerWeb.DeviceLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.UserDevices

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, assign(socket, devices: list_devices(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Device")
    |> assign(:device, UserDevices.get_device!(id, socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Device")
    |> assign(:device, UserDevices.build_device(%{}, socket.assigns.current_user))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Device")
    |> assign(:device, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    device = UserDevices.get_device!(id, socket.assigns.current_user)
    {:ok, _} = UserDevices.delete_device(device)

    {:noreply, assign(socket, :devices, list_devices(socket.assigns.current_user))}
  end

  defp list_devices(user) do
    UserDevices.list_devices(user)
    |> HomeServer.Repo.preload(:location)
  end

end
