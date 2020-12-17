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

  def factory(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    %__MODULE__{
      location_id: sensor_measurement_aggregate.location_id,
      resolution:  sensor_measurement_aggregate.resolution,
      quantity:    sensor_measurement_aggregate.quantity,
      unit:        sensor_measurement_aggregate.unit,
    }
  end
end
