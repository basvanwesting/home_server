defmodule HomeServer.LocationPlotQuery do
  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.SensorMeasurement

  def data_headers(location_id) do
    end_measured_at = DateTime.now!("Etc/UTC")
    start_measured_at = DateTime.add(end_measured_at, -3600, :second)
    data_headers(location_id, start_measured_at, end_measured_at)
  end
  def data_headers(location_id, start_measured_at, end_measured_at) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^location_id,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      order_by: [asc: sm.quantity],
      distinct: true,
      select: [sm.quantity, sm.unit]
    ) |> Enum.map(&List.to_tuple/1)
  end

  def raw_data(location_id, quantity, unit, start_measured_at, end_measured_at) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^location_id,
      where: sm.quantity == ^quantity,
      where: sm.unit == ^unit,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      order_by: [asc: sm.measured_at],
      select: [sm.measured_at, fragment("CAST(? as float)", sm.value)]
    ) |> Enum.map(&List.to_tuple/1)
  end

end
