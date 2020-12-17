defmodule HomeServer.SensorMeasurementAggregatorTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregator
  #alias HomeServer.SensorMeasurements.SensorMeasurementSeriesKey
  #alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_sensor_measurements(_) do
    %{id: location_id} = _location = location_fixture()

    sensor_measurements =
      for i <- 0..9 do
        sensor_measurement_fixture(%{
          measured_at: "2020-01-01T12:0#{div(i,4)}:0#{i}Z",
          quantity: "CO2",
          value: 400.0 + 2 * i,
          unit: "ppm",
          location_id: location_id,
        })
      end

    %{location_id: location_id, sensor_measurements: sensor_measurements}
  end

  describe "process, no existing aggregates" do
    setup [:create_sensor_measurements]
    test "insert new aggregates", %{sensor_measurements: sensor_measurements} do
      data = for aggregate <- SensorMeasurementAggregator.process(sensor_measurements, "minute") do
        aggregate
        |> Map.take([:measured_at, :average, :min, :max, :variance, :stddev, :count])
        |> Map.update!(:stddev, &(Float.round(&1,6)))
      end

      assert data ==
        [
          %{
            average: 404.0,
            count: 4,
            max: 406.0,
            measured_at: ~U[2020-01-01 12:00:00Z],
            min: 400.0,
            stddev: 1.632993,
            variance: 8.0,
          },
          %{
            average: 412.0,
            count: 4,
            max: 414.0,
            measured_at: ~U[2020-01-01 12:01:00Z],
            min: 408.0,
            stddev: 1.632993,
            variance: 8.0,
          },
          %{
            average: 418.0,
            count: 2,
            max: 418.0,
            measured_at: ~U[2020-01-01 12:02:00Z],
            min: 416.0,
            stddev: 0.0,
            variance: 0.0,
          }
        ]
    end
  end

end
