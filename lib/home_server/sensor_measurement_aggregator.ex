defmodule HomeServer.SensorMeasurementAggregator do
  @type sensor_measurement_list :: [SensorMeasurement.t()]
  @type aggregate_payload_tuples :: [{SensorMeasurementAggregate.t(), Payload.t()}]

  @resolutions ["minute", "hour", "day"]

  alias Ecto.Multi
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.SensorMeasurementAggregates

  defmodule Payload do
    @type t :: %__MODULE__{
        average: float,
        min: float,
        max: float,
        stddev: float,
        count: non_neg_integer,
        variance: float,
      }

    @attributes [:average, :min, :max, :stddev, :count, :variance]
    @enforce_keys @attributes
    defstruct     @attributes

    def attribute_list, do: @attributes
  end

  @spec process_batch(sensor_measurement_list) :: {:ok, any} | {:error, any}
  def process_batch(sensor_measurements) do
    aggregate_payload_tuples = build_aggregates(sensor_measurements)

    Multi.new()
    |> persist_aggregates(aggregate_payload_tuples)
    |> mark_sensor_measurements(sensor_measurements)
    |> Repo.transaction()
  end

  @spec build_aggregates(sensor_measurement_list) :: aggregate_payload_tuples
  def build_aggregates(sensor_measurements) do
    for resolution <- @resolutions do
      build_aggregates(sensor_measurements, resolution)
    end
    |> List.flatten()
  end

  @spec build_aggregates(sensor_measurement_list, binary) :: aggregate_payload_tuples
  def build_aggregates(sensor_measurements, resolution) do
    sensor_measurements
    |> Enum.reduce(%{}, fn (sensor_measurement, acc) ->
      {:ok, key} = SensorMeasurementAggregateKey.factory(sensor_measurement, resolution)

      case Map.has_key?(acc, key) || load_sensor_measurement_aggregate(key) do
        true ->
          Map.update!(acc, key, fn {aggregator, payload} ->
            {aggregator, append_payload(payload, sensor_measurement)}
          end)
        nil ->
          data = {
            SensorMeasurementAggregate.factory(key),
            build_payload(sensor_measurement)
          }
          Map.put(acc, key, data)
        %SensorMeasurementAggregate{} = aggregate ->
          payload =
            aggregate
            |> build_payload()
            |> append_payload(sensor_measurement)
          Map.put(acc, key, {aggregate, payload})

      end
    end)
    |> Map.values()
    |> Enum.map(fn {a, p} -> {a, set_stddev(p)} end)
  end

  @spec persist_aggregates(Multi.t(), aggregate_payload_tuples) :: Multi.t()
  def persist_aggregates(multi, aggregate_payload_tuples) do
    Enum.reduce(aggregate_payload_tuples, multi, fn {aggregate, payload}, acc ->
      key = SensorMeasurementAggregateKey.factory(aggregate)
      changeset = SensorMeasurementAggregate.changeset(aggregate, Map.from_struct(payload))
      Multi.insert_or_update(acc, key, changeset)
    end)
  end

  @spec mark_sensor_measurements(Multi.t(), sensor_measurement_list) :: Multi.t()
  def mark_sensor_measurements(multi, sensor_measurements) do
    Enum.reduce(sensor_measurements, multi, fn sensor_measurement, acc ->
      changeset = SensorMeasurement.changeset(sensor_measurement, %{aggregated: true})
      Multi.update(acc, sensor_measurement, changeset)
    end)
  end

  def load_sensor_measurement_aggregate(sensor_measurement_aggregate_key) do
    SensorMeasurementAggregates.get_sensor_measurement_aggregate_by_key(sensor_measurement_aggregate_key)
  end

  def build_payload(%SensorMeasurement{} = sensor_measurement) do
    %Payload{
      average:     sensor_measurement.value,
      min:         sensor_measurement.value,
      max:         sensor_measurement.value,
      stddev:      0.0,
      variance:    0.0,
      count:       1,
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
    variance = payload.variance + (sensor_measurement.value - payload.average) * (sensor_measurement.value - average)
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
