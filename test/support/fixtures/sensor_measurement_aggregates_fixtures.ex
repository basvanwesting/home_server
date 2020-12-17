defmodule HomeServer.SensorMeasurementAggregatesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeServer.SensorMeasurementAggregates` context.
  """

  alias HomeServer.SensorMeasurementAggregates

  def sensor_measurement_aggregate_fixture(attrs \\ %{}) do
    {:ok, sensor_measurement_aggregate} =
      attrs
      |> Enum.into(%{
        # location_id: 1,
        resolution: "hour",
        quantity: "Temperature",
        unit: "Celsius",
        measured_at: "2020-01-01T12:00:00Z",
        average: "22.0",
        min: "20.0",
        max: "25.0",
        stddev: "1.0",
        count: 60
      })
      |> SensorMeasurementAggregates.create_sensor_measurement_aggregate()

    sensor_measurement_aggregate
  end
end
