defmodule HomeServer.SensorMeasurements.SensorMeasurement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sensor_measurements" do
    field :location, :string
    field :measured_at, :utc_datetime
    field :quantity, :string
    field :source, :string
    field :unit, :string
    field :value, :decimal
  end

  @doc false
  def changeset(sensor_measurement, attrs) do
    sensor_measurement
    |> cast(attrs, [:measured_at, :quantity, :value, :unit, :location, :source])
    |> validate_required([:measured_at, :quantity, :value, :unit, :location, :source])
  end
end
