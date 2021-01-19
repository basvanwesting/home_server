defmodule HomeServer.LocationPlotQueryTest do
  use HomeServer.DataCase

  alias HomeServer.LocationPlotQuery
  alias HomeServer.LocationPlotQuery.PlotKey

  import HomeServer.SensorMeasurementAggregatesFixtures

  defp create_location_and_sensor_measurements(_) do
    location = Factory.insert(:location)

    for i <- 0..9 do
      sensor_measurement_aggregate_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "Temperature",
        value: 22.0 + i,
        unit: "C",
        location_id: location.id
      })

      sensor_measurement_aggregate_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "CO2",
        value: 400.0 + 2 * i,
        unit: "ppm",
        location_id: location.id
      })
    end

    %{location: location}
  end

  describe "data" do
    setup [:create_location_and_sensor_measurements]

    test "returns plot_keys", %{location: location} do
      result =
        LocationPlotQuery.plot_keys(
          location.id,
          :hour,
          {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"}
        )

      assert result == [
               %PlotKey{location_id: location.id, quantity: "CO2", unit: "ppm"},
               %PlotKey{location_id: location.id, quantity: "Temperature", unit: "C"}
             ]

      result = LocationPlotQuery.plot_keys(location.id)
      assert result == []
    end

    test "returns data with minute resolution, CO2", %{location: location} do
      plot_key = %PlotKey{location_id: location.id, quantity: "CO2", unit: "ppm"}

      result =
        LocationPlotQuery.data(plot_key, :hour, {"2020-01-01T12:01:00Z", "2020-01-01T12:07:00Z"})

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
