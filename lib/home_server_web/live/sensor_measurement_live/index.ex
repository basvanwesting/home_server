defmodule HomeServerWeb.SensorMeasurementLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurements
  alias HomeServer.SensorMeasurements.SensorMeasurement

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sensor_measurements, list_sensor_measurements())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sensor measurement")
    |> assign(:sensor_measurement, SensorMeasurements.get_sensor_measurement!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sensor measurement")
    |> assign(:sensor_measurement, %SensorMeasurement{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sensor measurements")
    |> assign(:sensor_measurement, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sensor_measurement = SensorMeasurements.get_sensor_measurement!(id)
    {:ok, _} = SensorMeasurements.delete_sensor_measurement(sensor_measurement)

    {:noreply, assign(socket, :sensor_measurements, list_sensor_measurements())}
  end

  defp list_sensor_measurements do
    SensorMeasurements.list_sensor_measurements()
  end
end
