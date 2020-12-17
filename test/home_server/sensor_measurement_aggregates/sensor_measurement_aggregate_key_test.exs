defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKeyTest do
  use ExUnit.Case, async: true

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.SensorMeasurements.SensorMeasurement

  describe "factory from sensor_measurement_aggregate" do
    test "from sensor_measurement_aggregate" do
      {:ok, key} =
        SensorMeasurementAggregateKey.factory(%SensorMeasurementAggregate{
          location_id: 1,
          resolution: "hour",
          quantity: "Temperature",
          unit: "Celsius",
          measured_at: ~U[2020-01-01 12:00:00Z],
          average: "22.0",
          min: "20.0",
          max: "25.0",
          stddev: "1.0",
          count: 60
        })

      assert key == %SensorMeasurementAggregateKey{
               location_id: 1,
               resolution: "hour",
               quantity: "Temperature",
               unit: "Celsius",
               measured_at: ~U[2020-01-01 12:00:00Z]
             }
    end

    test "from sensor_measurement with location_id and resolution" do
      {:ok, key} =
        SensorMeasurementAggregateKey.factory(
          %SensorMeasurement{
            location_id: 1,
            quantity: "Temperature",
            unit: "Celsius",
            measured_at: ~U[2020-01-01 12:34:46Z],
            value: "22.0",
            sensor: "A0"
          },
          "hour"
        )

      assert key == %SensorMeasurementAggregateKey{
               location_id: 1,
               resolution: "hour",
               quantity: "Temperature",
               unit: "Celsius",
               measured_at: ~U[2020-01-01 12:00:00Z]
             }
    end

    test "from sensor_measurement without location_id and resolution" do
      result =
        SensorMeasurementAggregateKey.factory(
          %SensorMeasurement{
            location_id: nil,
            quantity: "Temperature",
            unit: "Celsius",
            measured_at: ~U[2020-01-01 12:34:46Z],
            value: "22.0",
            sensor: "A0"
          },
          "hour"
        )

      assert result == {:error, "location_id must be present"}
    end
  end

  describe "measured_at_key" do
    test "minute resulution" do
      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:00:00Z], "minute")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:00:30Z], "minute")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:00:59Z], "minute")

      ~U[2020-01-01 12:01:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:01:00Z], "minute")
    end

    test "hour resulution" do
      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:00:00Z], "hour")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:30:30Z], "hour")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:59:59Z], "hour")

      ~U[2020-01-01 13:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 13:00:00Z], "hour")
    end

    test "day resulution" do
      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 00:00:00Z], "day")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 12:30:30Z], "day")

      ~U[2020-01-01 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-01 23:59:59Z], "day")

      ~U[2020-01-02 12:00:00Z] =
        SensorMeasurementAggregateKey.measured_at_key(~U[2020-01-02 00:00:00Z], "day")
    end
  end
end
