defmodule HomeServer.SensorMeasurementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeServer.SensorMeasurements` context.
  """

  alias HomeServer.SensorMeasurements

  def sensor_measurement_fixture(attrs \\ %{}) do
    {:ok, sensor_measurement} =
      attrs
      |> Enum.into(%{
        location: "some location",
        measured_at: "2020-01-01T12:00:00Z",
        quantity: "Temperature",
        value: "22.0",
        unit: "Celsius",
        source: "test-fixture",
      })
      |> SensorMeasurements.create_sensor_measurement()

    sensor_measurement
  end
end
