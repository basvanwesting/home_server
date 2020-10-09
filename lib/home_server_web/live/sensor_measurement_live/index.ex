defmodule HomeServerWeb.SensorMeasurementLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurements
  alias HomeServer.SensorMeasurements.SensorMeasurement

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: SensorMeasurements.subscribe()

    {:ok, assign(socket, :sensor_measurements, list_sensor_measurements(limit: 10)), temporary_assigns: [sensor_measurements: []]}
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
    {:noreply, socket}
  end

  @impl true
  def handle_info({:sensor_measurement_created, sensor_measurement}, socket) do
    socket =
      update(
        socket,
        :sensor_measurements,
        fn sensor_measurements -> [sensor_measurement | sensor_measurements] end
      )

    {:noreply, socket}
  end

  def handle_info({:sensor_measurement_deleted, sensor_measurement}, socket) do
    socket =
      update(
        socket,
        :sensor_measurements,
        fn sensor_measurements -> [sensor_measurement | sensor_measurements] end
      )

    {:noreply, socket}
  end

  defp list_sensor_measurements(args) do
    SensorMeasurements.list_sensor_measurements(args)
  end
end
