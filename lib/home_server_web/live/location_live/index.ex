defmodule HomeServerWeb.LocationLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.UserLocations

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, assign(socket, locations: UserLocations.list_locations(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Location")
    |> assign(:location, UserLocations.get_location!(id, socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Location")
    |> assign(:location, UserLocations.build_location(%{}, socket.assigns.current_user))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Location")
    |> assign(:location, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = UserLocations.get_location!(id, socket.assigns.current_user)
    {:ok, _} = UserLocations.delete_location(location)

    {:noreply,
     assign(socket, :locations, UserLocations.list_locations(socket.assigns.current_user))}
  end
end
