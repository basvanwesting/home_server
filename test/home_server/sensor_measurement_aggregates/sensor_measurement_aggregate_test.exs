defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateTest do
  use ExUnit.Case, async: true

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey

  describe "factory" do
    test "from sensor_measurement_aggregate_key" do
      aggregate =
        SensorMeasurementAggregate.factory(%SensorMeasurementAggregateKey{
          location_id: 1,
          resolution: "hour",
          quantity: "Temperature",
          unit: "Celsius",
          measured_at: ~U[2020-01-01 12:00:00Z]
        })

      assert aggregate == %SensorMeasurementAggregate{
               location_id: 1,
               resolution: "hour",
               quantity: "Temperature",
               unit: "Celsius",
               measured_at: ~U[2020-01-01 12:00:00Z],
               average: nil,
               min: nil,
               max: nil,
               stddev: nil,
               count: nil
             }
    end
  end
end
