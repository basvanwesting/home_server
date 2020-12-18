defmodule HomeServer.SensorMeasurementAggregator.Storage do
  @type aggregate_payload_tuple :: {SensorMeasurementAggregate.t(), Payload.t()}
  @type aggregate_payload_tuples :: [aggregate_payload_tuple]

  alias HomeServer.Repo
  alias Ecto.Multi
  import Ecto.Query

  alias HomeServer.SensorMeasurements.SensorMeasurement
  alias HomeServer.SensorMeasurementAggregates
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey

  @spec sensor_measurements_batch(non_neg_integer) :: [SensorMeasurement.t()]
  def sensor_measurements_batch(batch_size \\ 1000) do
    SensorMeasurement
    |> where([s], s.aggregated == false)
    |> where([s], not(is_nil(s.location_id)))
    |> limit(^batch_size)
    |> Repo.all()
  end

  @spec list_sensor_measurement_aggregates_by_keys([SensorMeasurementAggregateKey.t()]) :: [SensorMeasurementAggregate.t()]
  def list_sensor_measurement_aggregates_by_keys(keys) do
    SensorMeasurementAggregates.list_sensor_measurement_aggregates_by_keys(keys)
  end

  @spec persist_batch(aggregate_payload_tuples, [SensorMeasurement.t()]) :: tuple
  def persist_batch(aggregate_payload_tuples, sensor_measurements) do
    Multi.new()
    |> persist_aggregates(aggregate_payload_tuples)
    |> persist_handled_sensor_measurements(sensor_measurements)
    |> Repo.transaction()
  end

  @spec persist_aggregates(Multi.t(), aggregate_payload_tuples) :: Multi.t()
  defp persist_aggregates(multi, aggregate_payload_tuples) do
    {inserts, updates} = Enum.split_with(
      aggregate_payload_tuples,
      fn {aggregate, _} -> Ecto.get_meta(aggregate, :state) == :built end
    )

    multi
    |> persist_inserts(inserts)
    |> persist_updates(updates)
  end

  @spec persist_inserts(Multi.t(), aggregate_payload_tuples) :: Multi.t()
  defp persist_inserts(multi, aggregate_payload_tuples) do
    insert_attrs =
      aggregate_payload_tuples
      |> Enum.map(fn {aggregate, payload} ->
        Map.merge(
          to_storeable_map(aggregate),
          Map.from_struct(payload)
        ) end)
      |> Enum.map(fn attrs -> Map.drop(attrs, [:id, :variance]) end)

    Multi.insert_all(multi, :insert_all, SensorMeasurementAggregate, insert_attrs)
  end

  @spec persist_updates(Multi.t(), aggregate_payload_tuples) :: Multi.t()
  defp persist_updates(multi, aggregate_payload_tuples) do
    aggregate_payload_tuples
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {{aggregate, payload}, index}, acc ->
      changeset = SensorMeasurementAggregate.changeset(aggregate, Map.from_struct(payload))
      Multi.update(acc, "update #{index}", changeset)
    end)
  end

  @spec persist_handled_sensor_measurements(Multi.t(), [SensorMeasurement.t()]) :: Multi.t()
  defp persist_handled_sensor_measurements(multi, sensor_measurements) do
    sensor_measurement_ids = Enum.map(sensor_measurements, & &1.id)

    Multi.update_all(
      multi,
      :persist_handled_sensor_measurements,
      SensorMeasurement |> where([s], s.id in ^sensor_measurement_ids),
      set: [aggregated: true]
    )
  end

  @schema_meta_fields [:__meta__]
  defp to_storeable_map(struct) do
    association_fields = struct.__struct__.__schema__(:associations)
    waste_fields = association_fields ++ @schema_meta_fields
    struct |> Map.from_struct |> Map.drop(waste_fields)
  end
end
