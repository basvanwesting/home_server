defmodule HomeServer.LocationPlotQuery do
  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.{SensorMeasurement, SensorMeasurementSeriesKey}

  def plot_keys(location_id, timescale \\ :hour)
  def plot_keys(location_id, timescale) when is_atom(timescale) do
    plot_keys(location_id, measured_at_range_for_timescale(timescale))
  end
  def plot_keys(location_id, {start_measured_at, end_measured_at}) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^location_id,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      order_by: [asc: sm.quantity],
      distinct: true,
      select: [sm.quantity, sm.unit]
    ) |> Enum.map(fn [quantity, unit] -> %SensorMeasurementSeriesKey{location_id: location_id, quantity: quantity, unit: unit} end)
  end


  def data(plot_key, timescale \\ :hour)
  def data(plot_key, timescale) when is_atom(timescale) do
    data(plot_key, measured_at_range_for_timescale(timescale), measured_at_resolution_for_timescale(timescale))
  end
  def data(plot_key, {start_measured_at, end_measured_at}, measured_at_resolution) do
    Repo.all(
      from sm in SensorMeasurement,
      where: sm.location_id == ^plot_key.location_id,
      where: sm.quantity == ^plot_key.quantity,
      where: sm.unit == ^plot_key.unit,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      select: [
        fragment("DATE_TRUNC(?, ?)::timestamptz", ^measured_at_resolution, sm.measured_at),
        fragment("AVG(?)", sm.value)
      ],
      group_by: 1
    )
    |> Enum.map(fn [measured_at, value] -> {DateTime.truncate(measured_at, :second), value} end)
  end

  def measured_at_range_for_timescale(timescale \\ :hour, end_measured_at \\ DateTime.now!("Etc/UTC"))
  def measured_at_range_for_timescale(timescale, end_measured_at) do
    {start_measured_at_for(timescale, end_measured_at), end_measured_at}
  end
  def start_measured_at_for(:minute, end_measured_at), do: DateTime.add(end_measured_at, -60,        :second)
  def start_measured_at_for(:hour,   end_measured_at), do: DateTime.add(end_measured_at, -3600,      :second)
  def start_measured_at_for(:day,    end_measured_at), do: DateTime.add(end_measured_at, -3600*24,   :second)
  def start_measured_at_for(:week,   end_measured_at), do: DateTime.add(end_measured_at, -3600*24*7, :second)

  def measured_at_resolution_for_timescale(:minute), do: "second"
  def measured_at_resolution_for_timescale(:hour),   do: "minute"
  def measured_at_resolution_for_timescale(:day),    do: "hour"
  def measured_at_resolution_for_timescale(:week),   do: "hour"
end
