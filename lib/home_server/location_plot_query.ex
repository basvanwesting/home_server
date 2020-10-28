defmodule HomeServer.LocationPlotQuery do
  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.{SensorMeasurement, SensorMeasurementKey}

  def sensor_measurement_keys(location_id, timescale \\ :hour)
  def sensor_measurement_keys(location_id, timescale) when is_atom(timescale) do
    sensor_measurement_keys(location_id, measured_at_range_for_timescale(timescale))
  end
  def sensor_measurement_keys(location_id, {start_measured_at, end_measured_at}) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^location_id,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      order_by: [asc: sm.quantity],
      distinct: true,
      select: [sm.quantity, sm.unit]
    ) |> Enum.map(fn [quantity, unit] -> %SensorMeasurementKey{location_id: location_id, quantity: quantity, unit: unit} end)
  end

  def raw_data(sensor_measurement_key, timescale \\ :hour)
  def raw_data(sensor_measurement_key, timescale) when is_atom(timescale) do
    raw_data(sensor_measurement_key, measured_at_range_for_timescale(timescale))
  end
  def raw_data(sensor_measurement_key, {start_measured_at, end_measured_at}) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^sensor_measurement_key.location_id,
      where: sm.quantity == ^sensor_measurement_key.quantity,
      where: sm.unit == ^sensor_measurement_key.unit,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      order_by: [asc: sm.measured_at],
      select: [sm.measured_at, fragment("CAST(? as float)", sm.value)]
    ) |> Enum.map(&List.to_tuple/1)
  end

  def measured_at_range_for_timescale(timescale \\ :hour, end_measured_at \\ DateTime.now!("Etc/UTC"))
  def measured_at_range_for_timescale(timescale, end_measured_at) do
    {start_measured_at_for(timescale, end_measured_at), end_measured_at}
  end
  def start_measured_at_for(:minute, end_measured_at), do: DateTime.add(end_measured_at, -60,        :second)
  def start_measured_at_for(:hour,   end_measured_at), do: DateTime.add(end_measured_at, -3600,      :second)
  def start_measured_at_for(:day,    end_measured_at), do: DateTime.add(end_measured_at, -3600*24,   :second)
  def start_measured_at_for(:week,   end_measured_at), do: DateTime.add(end_measured_at, -3600*24*7, :second)

end
