defmodule HomeServerWeb.SensorMeasurementLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurements

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
     |> assign(:sensor_measurement, get_sensor_measurement!(id))}
  end

  defp page_title(:show), do: "Show Sensor measurement"

  defp get_sensor_measurement!(id) do
    SensorMeasurements.get_sensor_measurement!(id)
    |> HomeServer.Repo.preload(:location)
  end
end
