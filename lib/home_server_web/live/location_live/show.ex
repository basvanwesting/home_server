defmodule HomeServerWeb.LocationLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.UserLocations
  alias HomeServer.Locations
  alias HomeServer.LocationPlotQuery
  #alias HomeServer.SensorMeasurements.SensorMeasurementSeriesKey
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateSeriesKey
  alias HomeServerWeb.LocationLive.PlotComponent

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
    if connected?(socket), do: Locations.subscribe(location)

    plot_keys = LocationPlotQuery.plot_keys(location.id, socket.assigns.timescale)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       location: location,
       plot_keys: plot_keys
     )
    }
  end

  @impl true
  def handle_event("set_timescale_to_minute", _, socket), do: {:noreply, assign(socket, :timescale, :minute)}
  def handle_event("set_timescale_to_hour",   _, socket), do: {:noreply, assign(socket, :timescale, :hour)}
  def handle_event("set_timescale_to_day",    _, socket), do: {:noreply, assign(socket, :timescale, :day)}
  def handle_event("set_timescale_to_week",   _, socket), do: {:noreply, assign(socket, :timescale, :week)}

  @impl true
  def handle_info({:sensor_measurement_created, sensor_measurement}, socket) do
    with {:ok, plot_key} <- SensorMeasurementAggregateSeriesKey.factory(sensor_measurement, socket.assigns.timescale) do
      plot_component_id = PlotComponent.plot_component_id(plot_key)
      send_update PlotComponent, id: plot_component_id, sensor_measurement: sensor_measurement
      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
