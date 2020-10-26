defmodule HomeServerWeb.SensorMeasurementLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurements

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: SensorMeasurements.subscribe()

    {:ok, assign(socket, :sensor_measurements, list_sensor_measurements(limit: 10)), temporary_assigns: [sensor_measurements: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sensor measurements")
    |> assign(:sensor_measurement, nil)
  end

  @impl true
  def handle_info({:sensor_measurement_created, sensor_measurement}, socket) do
    socket =
      update(
        socket,
        :sensor_measurements,
        fn sensor_measurements -> [sensor_measurement |> HomeServer.Repo.preload(:location) | sensor_measurements] end
      )

    {:noreply, socket}
  end

  defp list_sensor_measurements(args) do
    SensorMeasurements.list_sensor_measurements(args)
    |> HomeServer.Repo.preload(:location)
  end
end
