defmodule HomeServer.LocationPlotQueryTest do
  use HomeServer.DataCase

  alias HomeServer.LocationPlotQuery
  alias HomeServer.SensorMeasurements.SensorMeasurementKey

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_location_and_sensor_measurements(_) do
    %{id: location_id} = location = location_fixture()

    for i <- 0..9 do
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        quantity: "Temperature",
        value: 22.0 + i,
        unit: "C",
        location_id: location_id,
      })
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        quantity: "CO2",
        value: 400.0 + i,
        unit: "ppm",
        location_id: location_id,
      })
    end

    %{location: location}
  end

  describe "data" do
    setup [:create_location_and_sensor_measurements]

    test "returns sensor_measurement_keys", %{location: location} do
      result = LocationPlotQuery.sensor_measurement_keys(location.id, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"})
      assert result == [
        %SensorMeasurementKey{location_id: location.id, quantity: "CO2", unit: "ppm"},
        %SensorMeasurementKey{location_id: location.id, quantity: "Temperature", unit: "C"},
      ]

      result = LocationPlotQuery.sensor_measurement_keys(location.id)
      assert result == []
    end

    test "returns raw data", %{location: location} do
      sensor_measurement_key = %SensorMeasurementKey{location_id: location.id, quantity: "Temperature", unit: "C"}
      result = LocationPlotQuery.raw_data(sensor_measurement_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"})
      assert result == [
        {~U[2020-01-01 12:01:00Z], 23.0},
        {~U[2020-01-01 12:02:00Z], 24.0},
        {~U[2020-01-01 12:03:00Z], 25.0},
        {~U[2020-01-01 12:04:00Z], 26.0},
        {~U[2020-01-01 12:05:00Z], 27.0},
        {~U[2020-01-01 12:06:00Z], 28.0},
        {~U[2020-01-01 12:07:00Z], 29.0},
        {~U[2020-01-01 12:08:00Z], 30.0}
      ]
    end
  end
end
