defmodule HomeServer.SensorMeasurementAggregator.Batch do
  @type sensor_measurement_list :: [SensorMeasurement.t()]
  @type aggregate_payload_tuple :: {SensorMeasurementAggregate.t(), Payload.t()}
  @type aggregate_payload_tuples :: [aggregate_payload_tuple]
  @type aggregate_payload_key_map :: %{
      SensorMeasurementAggregateKey.t() => {SensorMeasurementAggregate.t(), Payload.t()}
    }

  @resolutions ["minute", "hour", "day"]

  #alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.SensorMeasurementAggregator.{Payload, Storage}

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
    |> Enum.map(fn {a, p} -> {a, Payload.set_stddev(p)} end)
  end

  @spec enrich_aggregates(aggregate_payload_key_map, sensor_measurement_list, binary) ::
          aggregate_payload_key_map
  def enrich_aggregates(acc, sensor_measurements, resolution) do
    Enum.reduce(sensor_measurements, acc, fn sensor_measurement, acc ->
      {:ok, key} = SensorMeasurementAggregateKey.factory(sensor_measurement, resolution)

      if Map.has_key?(acc, key) do
        Map.update!(acc, key, fn {aggregator, payload} ->
          {aggregator, Payload.append_sensor_measurement(payload, sensor_measurement)}
        end)
      else
        data = {
          SensorMeasurementAggregate.factory(key),
          Payload.factory(sensor_measurement)
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
      Map.put(acc, key, {aggregate, Payload.factory(aggregate)})
    end)
  end

end
