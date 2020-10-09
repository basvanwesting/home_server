defmodule HomeServer.SensorMeasurements.SensorMeasurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sensor_measurements" do
    field :host, :string
    field :sensor, :string
    field :measured_at, :utc_datetime
    field :quantity, :string
    field :value, :decimal
    field :unit, :string
    field :location, :string
  end

  @doc false
  def changeset(sensor_measurement, attrs) do
    sensor_measurement
    |> cast(attrs, [:measured_at, :quantity, :value, :unit, :host, :sensor, :location])
    |> validate_required([:measured_at, :quantity, :value, :unit, :host, :sensor])
  end
end
