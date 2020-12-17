defmodule HomeServer.SensorMeasurementAggregatorTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregator
  alias HomeServer.SensorMeasurementAggregates
  #alias HomeServer.SensorMeasurements.SensorMeasurementSeriesKey
  #alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_sensor_measurements(_) do
    %{id: location_id} = _location = location_fixture()

    sensor_measurements =
      for i <- 0..9 do
        sensor_measurement_fixture(%{
          measured_at: "2020-01-01T13:0#{div(i,4)}:0#{i}Z",
          quantity: "CO2",
          value: 400.0 + 2 * i,
          unit: "ppm",
          location_id: location_id,
        })
      end

    %{location_id: location_id, sensor_measurements: sensor_measurements}
  end

  defp create_sensor_measurement_aggregates(context) do
    attrs = %{
      location_id: context.location_id,
      resolution: "minute",
      quantity: "CO2",
      unit: "ppm",
      average: 450.0,
      count: 2,
      max: 480.0,
      min: 440.0,
      measured_at: ~U[2020-01-01 13:01:00Z],
      stddev: 20.0
    }

    {:ok, sensor_measurement_aggregate} =
      SensorMeasurementAggregates.create_sensor_measurement_aggregate(attrs)

    Map.merge(context, %{
      sensor_measurement_aggregates: [sensor_measurement_aggregate]
    })
  end

  describe "build, with and without existing aggregates" do
    setup [:create_sensor_measurements, :create_sensor_measurement_aggregates]
    test "build new aggregates for resolution minute", %{sensor_measurements: sensor_measurements} do
      data = for {aggregate, payload} <- SensorMeasurementAggregator.build(sensor_measurements, "minute") do
        %{
          resolution: aggregate.resolution,
          measured_at: aggregate.measured_at,
          average:     payload.average,
          count:       payload.count,
          max:         payload.max,
          min:         payload.min,
          stddev:      Float.round(payload.stddev, 6),
        }
      end

      assert data ==
        [
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:00:00Z],
            average: 404.0,
            count: 4,
            max: 406.0,
            min: 400.0,
            stddev: 1.632993,
          },
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:01:00Z],
            average: 418.8,
            count: 6,
            max: 480.0,
            min: 408.0,
            stddev: 18.093093,
          },
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:02:00Z],
            average: 418.0,
            count: 2,
            max: 418.0,
            min: 416.0,
            stddev: 0.0,
          }
        ]
    end

    test "build new aggregates for resolution hour", %{sensor_measurements: sensor_measurements} do
      data = for {aggregate, payload} <- SensorMeasurementAggregator.build(sensor_measurements, "hour") do
        %{
          resolution: aggregate.resolution,
          measured_at: aggregate.measured_at,
          average:     payload.average,
          count:       payload.count,
          max:         payload.max,
          min:         payload.min,
          stddev:      Float.round(payload.stddev, 6),
        }
      end

      assert data ==
        [
          %{
            resolution: "hour",
            measured_at: ~U[2020-01-01 13:00:00Z],
            average: 410.0,
            count: 10,
            max: 418.0,
            min: 400.0,
            stddev: 5.163978,
          },
        ]
    end

    test "process new aggregates", %{sensor_measurements: sensor_measurements} do
      {:ok, _} = SensorMeasurementAggregator.process(sensor_measurements)

      data = for aggregate <- SensorMeasurementAggregates.list_sensor_measurement_aggregates() do
        aggregate
        |> Map.take([:resolution, :measured_at, :average, :min, :max, :stddev, :count])
        |> Map.update!(:stddev, &(Float.round(&1,6)))
      end

      assert data ==
        [
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:00:00Z],
            average: 404.0,
            count: 4,
            max: 406.0,
            min: 400.0,
            stddev: 1.632993,
          },
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:01:00Z],
            average: 418.8,
            count: 6,
            max: 480.0,
            min: 408.0,
            stddev: 18.093093,
          },
          %{
            resolution: "minute",
            measured_at: ~U[2020-01-01 13:02:00Z],
            average: 418.0,
            count: 2,
            max: 418.0,
            min: 416.0,
            stddev: 0.0,
          },
          %{
            resolution: "hour",
            measured_at: ~U[2020-01-01 13:00:00Z],
            average: 410.0,
            count: 10,
            max: 418.0,
            min: 400.0,
            stddev: 5.163978,
          },
          %{
            resolution: "day",
            measured_at: ~U[2020-01-01 12:00:00Z],
            average: 410.0,
            count: 10,
            max: 418.0,
            min: 400.0,
            stddev: 5.163978,
          },
        ]
    end
  end

end
