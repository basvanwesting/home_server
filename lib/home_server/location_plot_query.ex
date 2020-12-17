defmodule HomeServer.LocationPlotQuery do
  import Ecto.Query, warn: false
  alias HomeServer.Repo

  #alias HomeServer.SensorMeasurements.{SensorMeasurement, SensorMeasurementSeriesKey}
  alias HomeServer.SensorMeasurementAggregates.{SensorMeasurementAggregate, SensorMeasurementAggregateSeriesKey}

  def plot_keys(location_id, timescale \\ :hour)
  def plot_keys(location_id, timescale) when is_atom(timescale) do
    plot_keys(location_id, timescale, measured_at_range_for_timescale(timescale))
  end
  def plot_keys(location_id, timescale, {start_measured_at, end_measured_at}) do
    resolution = resolution_for_timescale(timescale)
    Repo.all(
      from s in SensorMeasurementAggregate,
      where: s.location_id == ^location_id,
      where: s.resolution == ^resolution,
      where: s.measured_at >= ^start_measured_at,
      where: s.measured_at <= ^end_measured_at,
      order_by: [asc: s.quantity],
      distinct: true,
      select: [s.quantity, s.unit]
    ) |> Enum.map(fn [quantity, unit] -> %SensorMeasurementAggregateSeriesKey{location_id: location_id, resolution: resolution, quantity: quantity, unit: unit} end)
  end


  def data(plot_key, timescale \\ :hour)
  def data(plot_key, timescale) when is_atom(timescale) do
    data(plot_key, measured_at_range_for_timescale(timescale))
  end
  def data(plot_key, {start_measured_at, end_measured_at}) do
    Repo.all(
      from sm in SensorMeasurementAggregate,
      where: sm.location_id == ^plot_key.location_id,
      where: sm.resolution == ^plot_key.resolution,
      where: sm.quantity == ^plot_key.quantity,
      where: sm.unit == ^plot_key.unit,
      where: sm.measured_at >= ^start_measured_at,
      where: sm.measured_at <= ^end_measured_at,
      select: [
        sm.measured_at,
        sm.max,
        sm.average + sm.stddev,
        sm.average,
        sm.average - sm.stddev,
        sm.min,
      ]
    )
    |> Enum.map(fn [measured_at | data] -> [DateTime.truncate(measured_at, :second) | data] end)
  end

  def measured_at_range_for_timescale(timescale \\ :hour, end_measured_at \\ DateTime.now!("Etc/UTC"))
  def measured_at_range_for_timescale(timescale, end_measured_at) do
    {start_measured_at_for(timescale, end_measured_at), end_measured_at}
  end
  def start_measured_at_for(:minute, end_measured_at), do: DateTime.add(end_measured_at, -60,        :second)
  def start_measured_at_for(:hour,   end_measured_at), do: DateTime.add(end_measured_at, -3600,      :second)
  def start_measured_at_for(:day,    end_measured_at), do: DateTime.add(end_measured_at, -3600*24,   :second)
  def start_measured_at_for(:week,   end_measured_at), do: DateTime.add(end_measured_at, -3600*24*7, :second)

  def resolution_for_timescale(:minute), do: "minute"
  def resolution_for_timescale(:hour),   do: "minute"
  def resolution_for_timescale(:day),    do: "hour"
  def resolution_for_timescale(:week),   do: "day"
end
