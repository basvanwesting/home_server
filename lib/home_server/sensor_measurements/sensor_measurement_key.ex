defmodule HomeServer.SensorMeasurements.SensorMeasurementKey do
  @type t :: %__MODULE__{
      location_id: non_neg_integer,
      quantity: binary,
      unit: binary,
    }

  @enforce_keys [:location_id, :quantity, :unit]
  defstruct     [:location_id, :quantity, :unit]

  alias HomeServer.SensorMeasurements.SensorMeasurement

  def factory(%SensorMeasurement{} = sensor_measurement) do
    %__MODULE__{
      location_id: sensor_measurement.location_id,
      quantity:    sensor_measurement.quantity,
      unit:        sensor_measurement.unit,
    }
  end
end
