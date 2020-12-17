defmodule HomeServer.LocationPlotQueryTest do
  use HomeServer.DataCase

  alias HomeServer.LocationPlotQuery
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateSeriesKey

  import HomeServer.SensorMeasurementAggregatesFixtures
  import HomeServer.LocationsFixtures

  defp create_location_and_sensor_measurements(_) do
    %{id: location_id} = location = location_fixture()

    for i <- 0..9 do
      sensor_measurement_aggregate_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "Temperature",
        value: 22.0 + i,
        unit: "C",
        location_id: location_id,
      })
      sensor_measurement_aggregate_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "CO2",
        value: 400.0 + 2 * i,
        unit: "ppm",
        location_id: location_id,
      })
    end

    %{location: location}
  end

  describe "data" do
    setup [:create_location_and_sensor_measurements]

    test "returns plot_keys", %{location: location} do
      result = LocationPlotQuery.plot_keys(location.id, :hour, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"})
      assert result == [
        %SensorMeasurementAggregateSeriesKey{location_id: location.id, resolution: "minute", quantity: "CO2", unit: "ppm"},
        %SensorMeasurementAggregateSeriesKey{location_id: location.id, resolution: "minute", quantity: "Temperature", unit: "C"},
      ]

      result = LocationPlotQuery.plot_keys(location.id)
      assert result == []
    end

    test "returns data with minute resolution, CO2", %{location: location} do
      plot_key = %SensorMeasurementAggregateSeriesKey{location_id: location.id, resolution: "minute", quantity: "CO2", unit: "ppm"}
      result = LocationPlotQuery.data(plot_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:07:00Z"})
      assert result == [
        [~U[2020-01-01 12:01:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:02:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:03:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:04:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:05:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:06:00Z], 25.0, 23.0, 22.0, 21.0, 20.0],
        [~U[2020-01-01 12:07:00Z], 25.0, 23.0, 22.0, 21.0, 20.0]
      ]
    end

  end
end
