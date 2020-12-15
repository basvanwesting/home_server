defmodule HomeServer.SensorMeasurementAggregatorTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregator
  alias HomeServer.SensorMeasurements.SensorMeasurementKey
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_location_and_sensor_measurements(_) do
    %{id: location_id} = _location = location_fixture()

    for i <- 0..9 do
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:0#{i}Z",
        quantity: "Temperature",
        value: 22.01234 + i,
        unit: "C",
        location_id: location_id,
      })
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:0#{i}Z",
        quantity: "CO2",
        value: 400.01234 + 2 * i,
        unit: "ppm",
        location_id: location_id,
      })
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T13:0#{i}:0#{i}Z",
        quantity: "CO2",
        value: 401.01234 + 2 * i,
        unit: "ppm",
        location_id: location_id,
      })
    end

    %{location_id: location_id}
  end

  describe "data" do
    setup [:create_location_and_sensor_measurements]

    test "returns sensor_measurement_keys", %{location_id: location_id} do
      result = SensorMeasurementAggregator.sensor_measurement_keys()
      assert result == [
        %SensorMeasurementKey{location_id: location_id, quantity: "CO2", unit: "ppm"},
        %SensorMeasurementKey{location_id: location_id, quantity: "Temperature", unit: "C"},
      ]
    end

    test "returns data with hour resolution, CO2", %{location_id: location_id} do
      sensor_measurement_key = %SensorMeasurementKey{location_id: location_id, quantity: "CO2", unit: "ppm"}
      result = SensorMeasurementAggregator.calculate_for_key(sensor_measurement_key, "hour")
      assert result == [
        %{average: 409.0, count: 10, max: 418.0, measured_at: ~U[2020-01-01 12:00:00Z], min: 400.0, stddev: 6.1},
        %{average: 410.0, count: 10, max: 419.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 401.0, stddev: 6.1},
      ]
    end

    test "insert or updated sensor_measurement_aggregates", %{location_id: location_id} do
      sensor_measurement_key = %SensorMeasurementKey{location_id: location_id, quantity: "CO2", unit: "ppm"}
      aggregate_data = %{average: 409.0, count: 10, max: 418.0, measured_at: ~U[2020-01-01 12:00:00Z], min: 400.0, stddev: 6.1}
      result = SensorMeasurementAggregator.replace_for_key(sensor_measurement_key, "hour", aggregate_data)
      assert {:ok, %SensorMeasurementAggregate{} = record} = result
      assert record.location_id == location_id
      assert record.quantity == "CO2"
      assert record.unit == "ppm"
      assert record.resolution == "hour"
      assert record.average == Decimal.cast(409.0) |> elem(1)
      assert record.count == 10
      assert record.max == Decimal.cast(418.0) |> elem(1)
      assert record.measured_at == ~U[2020-01-01 12:00:00Z]
      assert record.min == Decimal.cast(400.0) |> elem(1)
      assert record.stddev == Decimal.cast(6.1) |> elem(1)
    end

  end
end
