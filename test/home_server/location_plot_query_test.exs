defmodule HomeServer.LocationPlotQueryTest do
  use HomeServer.DataCase

  alias HomeServer.LocationPlotQuery
  alias HomeServer.LocationPlotQuery.PlotKey

  defp create_location_and_sensor_measurements(_) do
    location = Factory.insert(:location)

    for i <- 0..9 do
      Factory.insert(
        :sensor_measurement_aggregate,
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "Temperature",
        average: 22.0 + i,
        unit: "C",
        location_id: location.id
      )

      Factory.insert(
        :sensor_measurement_aggregate,
        measured_at: "2020-01-01T12:0#{i}:00Z",
        resolution: "minute",
        quantity: "CO2",
        average: 400.0 + 2 * i,
        unit: "ppm",
        location_id: location.id
      )
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
               [~U[2020-01-01 12:01:00Z], 25.0, 403.0, 402.0, 401.0, 20.0],
               [~U[2020-01-01 12:02:00Z], 25.0, 405.0, 404.0, 403.0, 20.0],
               [~U[2020-01-01 12:03:00Z], 25.0, 407.0, 406.0, 405.0, 20.0],
               [~U[2020-01-01 12:04:00Z], 25.0, 409.0, 408.0, 407.0, 20.0],
               [~U[2020-01-01 12:05:00Z], 25.0, 411.0, 410.0, 409.0, 20.0],
               [~U[2020-01-01 12:06:00Z], 25.0, 413.0, 412.0, 411.0, 20.0],
               [~U[2020-01-01 12:07:00Z], 25.0, 415.0, 414.0, 413.0, 20.0]
             ]
    end
  end
end
