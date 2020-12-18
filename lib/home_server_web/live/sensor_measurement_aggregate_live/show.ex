defmodule HomeServerWeb.SensorMeasurementAggregateLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurementAggregates

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
     |> assign(:sensor_measurement_aggregate, get_sensor_measurement_aggregate!(id))}
  end

  defp page_title(:show), do: "Show Sensor measurement_aggregate"

  defp get_sensor_measurement_aggregate!(id) do
    SensorMeasurementAggregates.get_sensor_measurement_aggregate!(id)
    |> HomeServer.Repo.preload(:location)
  end
end
