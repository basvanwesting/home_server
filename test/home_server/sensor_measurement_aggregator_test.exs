defmodule HomeServer.SensorMeasurementAggregatorTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregator
  alias HomeServer.SensorMeasurementAggregates
  alias HomeServer.SensorMeasurements.SensorMeasurement
  #alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures
  import Ecto.Query, only: [from: 2]

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

    sensor_measurement = sensor_measurement_fixture(%{
      measured_at: "2020-01-01T11:12:13",
      quantity: "CO2",
      value: 400.0,
      unit: "ppm",
      location_id: location_id,
    })

    %{location_id: location_id, sensor_measurements: [sensor_measurement | sensor_measurements]}
  end

  defp create_sensor_measurement_aggregates(context) do
    attrs = [
      %{
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
      },
      %{
        location_id: context.location_id,
        resolution: "hour",
        quantity: "CO2",
        unit: "ppm",
        average: 450.0,
        count: 2,
        max: 480.0,
        min: 440.0,
        measured_at: ~U[2020-01-01 09:00:00Z],
        stddev: 20.0
      },
    ]

    sensor_measurement_aggregates =
      for attr <- attrs do
        {:ok, sensor_measurement_aggregate} =
          SensorMeasurementAggregates.create_sensor_measurement_aggregate(attr)
        sensor_measurement_aggregate
      end

    Map.merge(context, %{
      sensor_measurement_aggregates: sensor_measurement_aggregates
    })
  end

  describe "build_aggregates, with and without existing aggregates" do
    setup [:create_sensor_measurements, :create_sensor_measurement_aggregates]
    test "build_aggregates new aggregates for resolution minute", %{sensor_measurements: sensor_measurements} do
      data = for {aggregate, payload} <- SensorMeasurementAggregator.build_aggregates(sensor_measurements, "minute") do
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

      assert_lists_equal data, [
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:12:00Z], min: 400.0, resolution: "minute", stddev: 0.0},
        %{average: 403.0, count: 4, max: 406.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "minute", stddev: 2.581989},
        %{average: 424.0, count: 6, max: 480.0, measured_at: ~U[2020-01-01 13:01:00Z], min: 408.0, resolution: "minute", stddev: 22.126907},
        %{average: 417.0, count: 2, max: 418.0, measured_at: ~U[2020-01-01 13:02:00Z], min: 416.0, resolution: "minute", stddev: 1.414214}
      ]
    end

    test "build_aggregates new aggregates for resolution hour", %{sensor_measurements: sensor_measurements} do
      data = for {aggregate, payload} <- SensorMeasurementAggregator.build_aggregates(sensor_measurements, "hour") do
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

      assert_lists_equal data, [
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:00:00Z], min: 400.0, resolution: "hour", stddev: 0.0},
        %{average: 409.0, count: 10, max: 418.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "hour", stddev: 6.055301}
      ]
    end

    test "process_batch new aggregates", %{sensor_measurements: sensor_measurements} do
      {:ok, _} = SensorMeasurementAggregator.process_batch(sensor_measurements)

      data = for aggregate <- SensorMeasurementAggregates.list_sensor_measurement_aggregates() do
        aggregate
        |> Map.take([:resolution, :measured_at, :average, :min, :max, :stddev, :count])
        |> Map.update!(:average, &(Float.round(&1,1)))
        |> Map.update!(:stddev, &(Float.round(&1,6)))
      end

      assert_lists_equal data, [
        %{average: 450.0, count: 2, max: 480.0, measured_at: ~U[2020-01-01 09:00:00Z], min: 440.0, resolution: "hour", stddev: 20.0},
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:12:00Z], min: 400.0, resolution: "minute", stddev: 0.0},
        %{average: 403.0, count: 4, max: 406.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "minute", stddev: 2.581989},
        %{average: 424.0, count: 6, max: 480.0, measured_at: ~U[2020-01-01 13:01:00Z], min: 408.0, resolution: "minute", stddev: 22.126907},
        %{average: 417.0, count: 2, max: 418.0, measured_at: ~U[2020-01-01 13:02:00Z], min: 416.0, resolution: "minute", stddev: 1.414214},
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:00:00Z], min: 400.0, resolution: "hour", stddev: 0.0},
        %{average: 409.0, count: 10, max: 418.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "hour", stddev: 6.055301},
        %{average: 408.2, count: 11, max: 418.0, measured_at: ~U[2020-01-01 12:00:00Z], min: 400.0, resolution: "day", stddev: 6.353238}
      ]

      query = from s in SensorMeasurement,
        distinct: true,
        select: s.aggregated

      assert Repo.all(query) == [true]
    end

    test "process unaggregated sensor measurements" do
      IO.inspect("### START ###")
      result = SensorMeasurementAggregator.process(4)
      IO.inspect("### END ###")

      data = for aggregate <- SensorMeasurementAggregates.list_sensor_measurement_aggregates() do
        aggregate
        |> Map.take([:resolution, :measured_at, :average, :min, :max, :stddev, :count])
        |> Map.update!(:average, &(Float.round(&1,1)))
        |> Map.update!(:stddev, &(Float.round(&1,6)))
      end

      assert_lists_equal data, [
        %{average: 450.0, count: 2, max: 480.0, measured_at: ~U[2020-01-01 09:00:00Z], min: 440.0, resolution: "hour", stddev: 20.0},
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:12:00Z], min: 400.0, resolution: "minute", stddev: 0.0},
        %{average: 403.0, count: 4, max: 406.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "minute", stddev: 2.581989},
        %{average: 424.0, count: 6, max: 480.0, measured_at: ~U[2020-01-01 13:01:00Z], min: 408.0, resolution: "minute", stddev: 22.126907},
        %{average: 417.0, count: 2, max: 418.0, measured_at: ~U[2020-01-01 13:02:00Z], min: 416.0, resolution: "minute", stddev: 1.414214},
        %{average: 400.0, count: 1, max: 400.0, measured_at: ~U[2020-01-01 11:00:00Z], min: 400.0, resolution: "hour", stddev: 0.0},
        %{average: 409.0, count: 10, max: 418.0, measured_at: ~U[2020-01-01 13:00:00Z], min: 400.0, resolution: "hour", stddev: 6.055301},
        %{average: 408.2, count: 11, max: 418.0, measured_at: ~U[2020-01-01 12:00:00Z], min: 400.0, resolution: "day", stddev: 6.353238}
      ]

      query = from s in SensorMeasurement,
        distinct: true,
        select: s.aggregated

      assert Repo.all(query) == [true]
    end
  end

end
