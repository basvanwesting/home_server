defmodule HomeServer.LocationPlotQueryTest do
  use HomeServer.DataCase

  alias HomeServer.LocationPlotQuery
  alias HomeServer.SensorMeasurements.SensorMeasurementSeriesKey

  import HomeServer.SensorMeasurementsFixtures
  import HomeServer.LocationsFixtures

  defp create_location_and_sensor_measurements(_) do
    %{id: location_id} = location = location_fixture()

    for i <- 0..9 do
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:0#{i}Z",
        quantity: "Temperature",
        value: 22.0 + i,
        unit: "C",
        location_id: location_id,
      })
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:0#{i}Z",
        quantity: "CO2",
        value: 400.0 + 2 * i,
        unit: "ppm",
        location_id: location_id,
      })
      sensor_measurement_fixture(%{
        measured_at: "2020-01-01T12:0#{i}:3#{i}Z",
        quantity: "CO2",
        value: 401.0 + 2 * i,
        unit: "ppm",
        location_id: location_id,
      })
    end

    %{location: location}
  end

  describe "data" do
    setup [:create_location_and_sensor_measurements]

    test "returns sensor_measurement_series_keys", %{location: location} do
      result = LocationPlotQuery.sensor_measurement_series_keys(location.id, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"})
      assert result == [
        %SensorMeasurementSeriesKey{location_id: location.id, quantity: "CO2", unit: "ppm"},
        %SensorMeasurementSeriesKey{location_id: location.id, quantity: "Temperature", unit: "C"},
      ]

      result = LocationPlotQuery.sensor_measurement_series_keys(location.id)
      assert result == []
    end

    test "returns data with second resolution, Temperature", %{location: location} do
      sensor_measurement_series_key = %SensorMeasurementSeriesKey{location_id: location.id, quantity: "Temperature", unit: "C"}
      result = LocationPlotQuery.data(sensor_measurement_series_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"}, "second")
      assert result == [
        {~U[2020-01-01 12:01:01Z], 23.0},
        {~U[2020-01-01 12:02:02Z], 24.0},
        {~U[2020-01-01 12:03:03Z], 25.0},
        {~U[2020-01-01 12:04:04Z], 26.0},
        {~U[2020-01-01 12:05:05Z], 27.0},
        {~U[2020-01-01 12:06:06Z], 28.0},
        {~U[2020-01-01 12:07:07Z], 29.0},
      ]
    end

    test "returns data with second resolution, CO2", %{location: location} do
      sensor_measurement_series_key = %SensorMeasurementSeriesKey{location_id: location.id, quantity: "CO2", unit: "ppm"}
      result = LocationPlotQuery.data(sensor_measurement_series_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"}, "second")
      assert result == [
        {~U[2020-01-01 12:01:01Z], 402.0},
        {~U[2020-01-01 12:01:31Z], 403.0},
        {~U[2020-01-01 12:02:02Z], 404.0},
        {~U[2020-01-01 12:02:32Z], 405.0},
        {~U[2020-01-01 12:03:03Z], 406.0},
        {~U[2020-01-01 12:03:33Z], 407.0},
        {~U[2020-01-01 12:04:04Z], 408.0},
        {~U[2020-01-01 12:04:34Z], 409.0},
        {~U[2020-01-01 12:05:05Z], 410.0},
        {~U[2020-01-01 12:05:35Z], 411.0},
        {~U[2020-01-01 12:06:06Z], 412.0},
        {~U[2020-01-01 12:06:36Z], 413.0},
        {~U[2020-01-01 12:07:07Z], 414.0},
        {~U[2020-01-01 12:07:37Z], 415.0}
      ]
    end

    test "returns data with minute resolution, CO2", %{location: location} do
      sensor_measurement_series_key = %SensorMeasurementSeriesKey{location_id: location.id, quantity: "CO2", unit: "ppm"}
      result = LocationPlotQuery.data(sensor_measurement_series_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"}, "minute")
      assert result == [
        {~U[2020-01-01 12:01:00Z], 402.5},
        {~U[2020-01-01 12:02:00Z], 404.5},
        {~U[2020-01-01 12:03:00Z], 406.5},
        {~U[2020-01-01 12:04:00Z], 408.5},
        {~U[2020-01-01 12:05:00Z], 410.5},
        {~U[2020-01-01 12:06:00Z], 412.5},
        {~U[2020-01-01 12:07:00Z], 414.5}
      ]
    end

    test "returns data with hour resolution, CO2", %{location: location} do
      sensor_measurement_series_key = %SensorMeasurementSeriesKey{location_id: location.id, quantity: "CO2", unit: "ppm"}
      result = LocationPlotQuery.data(sensor_measurement_series_key, {"2020-01-01T12:01:00Z", "2020-01-01T12:08:00Z"}, "hour")
      assert result == [{~U[2020-01-01 12:00:00Z], 408.5}]
    end
  end
end
