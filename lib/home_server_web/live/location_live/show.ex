defmodule HomeServerWeb.LocationLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.UserLocations
  alias HomeServer.LocationPlotQuery

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(:timescale, :day)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location = UserLocations.get_location!(id, socket.assigns.current_user)
    plot_keys = LocationPlotQuery.plot_keys(location.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       location: location,
       plot_keys: plot_keys
     )}
  end

  @impl true
  def handle_event("set_timescale_to_hour", _, socket),
    do: {:noreply, assign(socket, :timescale, :hour)}

  def handle_event("set_timescale_to_day", _, socket),
    do: {:noreply, assign(socket, :timescale, :day)}

  def handle_event("set_timescale_to_week", _, socket),
    do: {:noreply, assign(socket, :timescale, :week)}

  def handle_event("set_timescale_to_month", _, socket),
    do: {:noreply, assign(socket, :timescale, :month)}

  def handle_event("set_timescale_to_year", _, socket),
    do: {:noreply, assign(socket, :timescale, :year)}

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
