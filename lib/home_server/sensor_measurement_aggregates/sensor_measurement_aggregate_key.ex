defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey do
  @type t :: %__MODULE__{
      location_id: non_neg_integer,
      resolution: binary,
      quantity: binary,
      unit: binary,
      measured_at: UtcDateTime.t(),
    }

  @attributes [:location_id, :resolution, :quantity, :unit, :measured_at]
  @enforce_keys @attributes
  defstruct     @attributes

  def attribute_list(), do: @attributes

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurements.SensorMeasurement

  def factory(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    struct(
      __MODULE__,
      Map.take(sensor_measurement_aggregate, @attributes)
    ) |> ok()
 end

  def factory(%SensorMeasurement{location_id: location_id} = sensor_measurement, resolution) when is_integer(location_id) do
    struct(
      __MODULE__,
      sensor_measurement
      |> Map.take([:location_id, :quantity, :unit, :measured_at])
      |> Map.update!(:measured_at, fn m -> measured_at_key(m, resolution) end)
      |> Map.put(:resolution, resolution)
    ) |> ok()
  end

  def factory(%SensorMeasurement{} = _sensor_measurement, _resolution), do: error("location_id must be present")

  def ok(key), do: {:ok, key}
  def error(reason), do: {:error, reason}

  def measured_at_key(measured_at, "minute"), do: %{measured_at | second: 0}
  def measured_at_key(measured_at, "hour"), do: %{measured_at | minute: 0, second: 0}
  def measured_at_key(measured_at, "day"), do: %{measured_at | hour: 12, minute: 0, second: 0}

end
