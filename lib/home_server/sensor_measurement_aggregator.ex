defmodule HomeServer.SensorMeasurementAggregator do
  @type sensor_measurement_list :: [SensorMeasurement.t()]
  @type sensor_measurement_aggregate_list :: [SensorMeasurement.t()]

  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.SensorMeasurementAggregates


  @spec process(sensor_measurement_list, binary) :: sensor_measurement_aggregate_list
  def process(sensor_measurements, resolution) do
    sensor_measurements
    |> Enum.reduce(%{}, fn (sensor_measurement, acc) ->
      {:ok, key} = SensorMeasurementAggregateKey.factory(sensor_measurement, resolution)
      case Map.get(acc, key) || load_sensor_measurement_aggregate(key) do
        nil ->
          Map.put(acc, key, build_sensor_measurement_aggregate(sensor_measurement, key))
        %SensorMeasurementAggregate{} = aggregate ->
          Map.put(acc, key, append_sensor_measurement_aggregate(aggregate, sensor_measurement))
      end
    end)
    |> Map.values()
    |> Enum.map(&set_stddev/1)
  end

  def build_sensor_measurement_aggregate(sensor_measurement, sensor_measurement_aggregate_key) do
    struct(
      SensorMeasurementAggregate,
      Map.merge(
        Map.from_struct(sensor_measurement_aggregate_key),
        %{
          average:     sensor_measurement.value,
          min:         sensor_measurement.value,
          max:         sensor_measurement.value,
          stddev:      Decimal.new("0"),
          variance:    Decimal.new("0"),
          count:       1,
        }
      )
    )
  end

  def load_sensor_measurement_aggregate(sensor_measurement_aggregate_key) do
    sensor_measurement_aggregate_key
    |> SensorMeasurementAggregates.get_sensor_measurement_aggregate_by_key()
    |> set_variance()
  end

  def append_sensor_measurement_aggregate(aggregate, sensor_measurement) do
    average = Decimal.add(aggregate.average, Decimal.div(Decimal.sub(sensor_measurement.value, aggregate.average), aggregate.count))
    variance = Decimal.add(aggregate.variance, Decimal.mult(Decimal.sub(sensor_measurement.value, aggregate.average), Decimal.sub(sensor_measurement.value, average)))
    min = Decimal.min(aggregate.min, sensor_measurement.value)
    max = Decimal.max(aggregate.max, sensor_measurement.value)
    count = aggregate.count + 1

    #average = aggregate.average + (sensor_measurement.value - aggregate.average) / aggregate.count
    #variance = aggregate.variance + (sensor_measurement.value - aggregate.average) * (sensor_measurement.value - average)
    #min = min(aggregate.min, sensor_measurement.value)
    #max = max(aggregate.max, sensor_measurement.value)
    #count = aggregate.count + 1

    %{aggregate | average: average, min: min, max: max, variance: variance, count: count}
  end

  def set_variance(nil), do: nil
  def set_variance(aggregate) do
    variance = Decimal.mult(Decimal.mult(aggregate.stddev, aggregate.stddev), aggregate.count - 1)
    %{aggregate | variance: variance}
  end

  def set_stddev(nil), do: nil
  def set_stddev(%{count: count} = aggregate) when count <= 1 do
    %{aggregate | stddev: 0}
  end
  def set_stddev(%{count: count} = aggregate) when count > 1 do
    stddev = Decimal.sqrt(Decimal.div(aggregate.variance, aggregate.count - 1))
    %{aggregate | stddev: stddev}
  end

end
