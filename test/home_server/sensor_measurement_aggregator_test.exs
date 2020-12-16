defmodule HomeServer.SensorMeasurementAggregatorTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregator
  alias HomeServer.SensorMeasurements.SensorMeasurementKey
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_sensor_measurements(_) do
    %{id: location_id} = _location = location_fixture()
    sensor_measurement_key = %SensorMeasurementKey{
      location_id: location_id,
      quantity: "CO2",
      unit: "ppm",
    }

    sensor_measurements =
      for i <- 0..9 do
        sensor_measurement_fixture(%{
          measured_at: "2020-01-01T12:0#{div(i,4)}:0#{i}Z",
          quantity: "CO2",
          value: 400.01234 + 2 * i,
          unit: "ppm",
          location_id: location_id,
        })
      end

    %{location_id: location_id, sensor_measurement_key: sensor_measurement_key, sensor_measurements: sensor_measurements}
  end

  describe "process, no existing aggregates" do
    setup [:create_sensor_measurements]
    test "insert new aggregates", %{sensor_measurement_key: sensor_measurement_key, sensor_measurements: sensor_measurements} do
      aggregators = SensorMeasurementAggregator.process(sensor_measurements, "minute")
      assert(
        Enum.map(aggregators, &(Map.take(&1, [:measured_at, :average, :min, :max, :variance, :stddev, :count]))) ==
        [
          %{
            average: Decimal.new("404.01234"),
            count: 4,
            max: Decimal.new("406.01234"),
            measured_at: ~U[2020-01-01 12:00:00Z],
            min: Decimal.new("400.01234"),
            stddev: Decimal.new("1.632993161855452065464856050"),
            variance: Decimal.new("8.0000000000"),
          },
          %{
            average: Decimal.new("412.01234"),
            count: 4,
            max: Decimal.new("414.01234"),
            measured_at: ~U[2020-01-01 12:01:00Z],
            min: Decimal.new("408.01234"),
            stddev: Decimal.new("1.632993161855452065464856050"),
            variance: Decimal.new("8.0000000000"),
          },
          %{
            average: Decimal.new("418.01234"),
            count: 2,
            max: Decimal.new("418.01234"),
            measured_at: ~U[2020-01-01 12:02:00Z],
            min: Decimal.new("416.01234"),
            stddev: Decimal.new("0.00000"),
            variance: Decimal.new("0E-10"),
          }
        ]
      )
    end
  end

end
