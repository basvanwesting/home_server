defmodule HomeServer.SensorMeasurementAggregator do
  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.{SensorMeasurement, SensorMeasurementKey}
  alias HomeServer.SensorMeasurementAggregates

  def process_hourly() do
    for sensor_measurement_key <- sensor_measurement_keys() do
      for aggregate_data <- calculate_for_key(sensor_measurement_key, "hour") do
        replace_for_key(sensor_measurement_key, "hour", aggregate_data)
      end
    end
  end

  def sensor_measurement_keys() do
    Repo.all(
      from sm in SensorMeasurement,
      distinct: true,
      select: [sm.location_id, sm.quantity, sm.unit],
      order_by: [asc: sm.location_id],
      order_by: [asc: sm.quantity]

    ) |> Enum.map(fn [location_id, quantity, unit] -> %SensorMeasurementKey{location_id: location_id, quantity: quantity, unit: unit} end)
  end

  def calculate_for_key(sensor_measurement_key, resolution) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^sensor_measurement_key.location_id,
      where: sm.quantity == ^sensor_measurement_key.quantity,
      where: sm.unit == ^sensor_measurement_key.unit,
      select: [
        fragment("DATE_TRUNC(?, ?)::timestamptz", ^resolution, sm.measured_at),
        fragment("CAST(ROUND(AVG(?), 1) as float)", sm.value),
        fragment("CAST(ROUND(MIN(?), 1) as float)", sm.value),
        fragment("CAST(ROUND(MAX(?), 1) as float)", sm.value),
        fragment("CAST(ROUND(STDDEV(?), 1) as float)", sm.value),
        fragment("COUNT(?)", sm.id),
      ],
      group_by: 1
    )
    |> Enum.map(fn [measured_at, average, min, max, stddev, count] -> %{
      measured_at: DateTime.truncate(measured_at, :second),
      average: average,
      min: min,
      max: max,
      stddev: stddev || 0,
      count: count
    } end)
  end

  def replace_for_key(sensor_measurement_key, resolution, aggregate_data) do
    Map.merge(aggregate_data, %{
      location_id: sensor_measurement_key.location_id,
      quantity: sensor_measurement_key.quantity,
      unit: sensor_measurement_key.unit,
      resolution: resolution,
    })
    |> SensorMeasurementAggregates.create_sensor_measurement_aggregate()
  end

end
