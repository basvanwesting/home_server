defmodule HomeServer.SensorMeasurementAggregator.Payload do
  alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

  @type t :: %__MODULE__{
          average: float,
          min: float,
          max: float,
          stddev: float,
          variance: float,
          count: non_neg_integer
        }

  @attributes [:average, :min, :max, :stddev, :variance, :count]
  @enforce_keys @attributes
  defstruct @attributes

  def factory(%SensorMeasurement{} = sensor_measurement) do
    %__MODULE__{
      average: sensor_measurement.value,
      min: sensor_measurement.value,
      max: sensor_measurement.value,
      stddev: 0.0,
      variance: 0.0,
      count: 1
    }
  end

  def factory(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    attrs =
      sensor_measurement_aggregate
      |> Map.take(@attributes)

    struct(__MODULE__, attrs)
    |> set_variance()
  end

  def append_sensor_measurement(payload, sensor_measurement) do
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
