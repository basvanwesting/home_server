defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateSeriesKey do
  @type t :: %__MODULE__{
      location_id: non_neg_integer,
      resolution: binary,
      quantity: binary,
      unit: binary,
    }

  @attributes [:location_id, :resolution, :quantity, :unit]
  @enforce_keys @attributes
  defstruct     @attributes

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.SensorMeasurements.SensorMeasurement

  def factory(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    %__MODULE__{
      location_id: sensor_measurement_aggregate.location_id,
      resolution:  sensor_measurement_aggregate.resolution,
      quantity:    sensor_measurement_aggregate.quantity,
      unit:        sensor_measurement_aggregate.unit,
    } |> ok()
  end

  def factory(%SensorMeasurement{location_id: location_id} = sensor_measurement, resolution) when is_integer(location_id) do
    struct(
      __MODULE__,
      sensor_measurement
      |> Map.take([:location_id, :quantity, :unit])
      |> Map.put(:resolution, resolution)
    ) |> ok()
  end

  def factory(%SensorMeasurement{} = _sensor_measurement, _resolution), do: error("location_id must be present")

  def ok(key), do: {:ok, key}
  def error(reason), do: {:error, reason}
end
