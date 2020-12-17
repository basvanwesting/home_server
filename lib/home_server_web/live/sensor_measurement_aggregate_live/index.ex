defmodule HomeServerWeb.SensorMeasurementAggregateLive.Index do
  use HomeServerWeb, :live_view

  alias HomeServer.SensorMeasurementAggregates

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: SensorMeasurementAggregates.subscribe()

    {:ok,
     assign(
       socket,
       :sensor_measurement_aggregates,
       list_sensor_measurement_aggregates(limit: 10)
     ), temporary_assigns: [sensor_measurement_aggregates: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sensor measurement_aggregates")
    |> assign(:sensor_measurement_aggregate, nil)
  end

  @impl true
  def handle_info({:sensor_measurement_aggregate_created, sensor_measurement_aggregate}, socket) do
    socket =
      update(
        socket,
        :sensor_measurement_aggregates,
        fn sensor_measurement_aggregates ->
          [
            sensor_measurement_aggregate |> HomeServer.Repo.preload(:location)
            | sensor_measurement_aggregates
          ]
        end
      )

    {:noreply, socket}
  end

  defp list_sensor_measurement_aggregates(args) do
    SensorMeasurementAggregates.list_sensor_measurement_aggregates(args)
    |> HomeServer.Repo.preload(:location)
  end
end
