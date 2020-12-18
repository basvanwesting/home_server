defmodule HomeServer.SensorMeasurementAggregator.Batch do
  @type sensor_measurement_list :: [SensorMeasurement.t()]
  @type aggregate_payload_tuple :: {SensorMeasurementAggregate.t(), Payload.t()}
  @type aggregate_payload_tuples :: [aggregate_payload_tuple]
  @type aggregate_payload_key_map :: %{
          SensorMeasurementAggregateKey.t() => {SensorMeasurementAggregate.t(), Payload.t()}
        }

  @resolutions ["minute", "hour", "day"]

  alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.SensorMeasurementAggregator.Storage

  defmodule Payload do
    @type t :: %__MODULE__{
            average: float,
            min: float,
            max: float,
            stddev: float,
            count: non_neg_integer,
            variance: float
          }

    @attributes [:average, :min, :max, :stddev, :count, :variance]
    @enforce_keys @attributes
    defstruct @attributes

    def attribute_list, do: @attributes
  end

  @spec process(sensor_measurement_list, integer) :: nil
  def process([], _), do: nil

  def process(sensor_measurements, batch_size) do
    result = sensor_measurements
    |> build_aggregates()
    |> Storage.persist_batch(sensor_measurements)

    if elem(result, 0) != :ok, do: raise result

    batch_size
    |> Storage.sensor_measurements_batch()
    |> process(batch_size)
  end

  @spec build_aggregates(sensor_measurement_list) :: aggregate_payload_tuples
  def build_aggregates(sensor_measurements) do
    sensor_measurements
    |> prepare_aggregates()
    |> enrich_aggregates(sensor_measurements, "minute")
    |> enrich_aggregates(sensor_measurements, "hour")
    |> enrich_aggregates(sensor_measurements, "day")
    |> Map.values()
    |> Enum.map(fn {a, p} -> {a, set_stddev(p)} end)
  end

  @spec enrich_aggregates(aggregate_payload_key_map, sensor_measurement_list, binary) ::
          aggregate_payload_key_map
  def enrich_aggregates(acc, sensor_measurements, resolution) do
    Enum.reduce(sensor_measurements, acc, fn sensor_measurement, acc ->
      {:ok, key} = SensorMeasurementAggregateKey.factory(sensor_measurement, resolution)

      if Map.has_key?(acc, key) do
        Map.update!(acc, key, fn {aggregator, payload} ->
          {aggregator, append_payload(payload, sensor_measurement)}
        end)
      else
        data = {
          SensorMeasurementAggregate.factory(key),
          build_payload(sensor_measurement)
        }

        Map.put(acc, key, data)
      end
    end)
  end

  @spec prepare_aggregates(sensor_measurement_list) :: aggregate_payload_key_map
  def prepare_aggregates(sensor_measurements) do
    for sensor_measurement <- sensor_measurements do
      for resolution <- @resolutions do
        {:ok, key} = SensorMeasurementAggregateKey.factory(sensor_measurement, resolution)
        key
      end
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Storage.list_sensor_measurement_aggregates_by_keys()
    |> Enum.reduce(%{}, fn aggregate, acc ->
      {:ok, key} = SensorMeasurementAggregateKey.factory(aggregate)
      Map.put(acc, key, {aggregate, build_payload(aggregate)})
    end)
  end

  def build_payload(%SensorMeasurement{} = sensor_measurement) do
    %Payload{
      average: sensor_measurement.value,
      min: sensor_measurement.value,
      max: sensor_measurement.value,
      stddev: 0.0,
      variance: 0.0,
      count: 1
    }
  end

  def build_payload(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    attrs =
      sensor_measurement_aggregate
      |> Map.take(Payload.attribute_list())
      |> set_variance()

    struct(Payload, attrs)
  end

  def append_payload(payload, sensor_measurement) do
    count = payload.count + 1
    average = payload.average + (sensor_measurement.value - payload.average) / count

    variance =
      payload.variance +
        (sensor_measurement.value - payload.average) * (sensor_measurement.value - average)

    min = min(payload.min, sensor_measurement.value)
    max = max(payload.max, sensor_measurement.value)

    %{payload | average: average, min: min, max: max, variance: variance, count: count}
  end

  def set_variance(payload) do
    variance = payload.stddev * payload.stddev * (payload.count - 1)
    %{payload | variance: variance}
  end

  def set_stddev(%{count: count} = payload) when count <= 1 do
    %{payload | stddev: 0.0}
  end

  def set_stddev(%{count: count} = payload) when count > 1 do
    stddev = :math.sqrt(payload.variance / (payload.count - 1))
    %{payload | stddev: stddev}
  end
end
