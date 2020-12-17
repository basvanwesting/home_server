defmodule HomeServer.SensorMeasurementAggregator do
  @type sensor_measurement_list :: [SensorMeasurement.t()]
  @type sensor_measurement_aggregate_list :: [SensorMeasurementAggregate.t()]
  @type aggregate_payload_tuples :: [{SensorMeasurementAggregate.t(), Payload.t()}]

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

  @spec process(sensor_measurement_list, binary) :: :ok | {:error, binary}
  def process(sensor_measurements, resolution) do
    sensor_measurements
    |> build(resolution)
    |> persist()

    :ok
  end

  @spec build(sensor_measurement_list, binary) :: sensor_measurement_aggregate_list
  def build(sensor_measurements, resolution) do
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

  @spec persist(aggregate_payload_tuples) :: {:ok, any} | {:error, any}
  def persist(aggregate_payload_tuples) do
    Enum.reduce(aggregate_payload_tuples, Multi.new(), fn {aggregate, payload}, acc ->
      key = SensorMeasurementAggregateKey.factory(aggregate)
      changeset = SensorMeasurementAggregate.changeset(aggregate, Map.from_struct(payload))
      Multi.insert_or_update(acc, key, changeset)
    end)
    |> Repo.transaction()
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
    average = payload.average + (sensor_measurement.value - payload.average) / payload.count
    variance = payload.variance + (sensor_measurement.value - payload.average) * (sensor_measurement.value - average)
    min = min(payload.min, sensor_measurement.value)
    max = max(payload.max, sensor_measurement.value)
    count = payload.count + 1

    %{payload | average: average, min: min, max: max, variance: variance, count: count}
  end

  def set_variance(payload) do
    variance = payload.stddev * payload.stddev * (payload.count - 1)
    %{payload | variance: variance}
  end

  def set_stddev(%{count: count} = payload) when count <= 1 do
    %{payload | stddev: 0}
  end
  def set_stddev(%{count: count} = payload) when count > 1 do
    stddev = :math.sqrt(payload.variance / (payload.count - 1))
    %{payload | stddev: stddev}
  end

end
