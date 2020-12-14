defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.Locations.Location

  schema "sensor_measurement_aggregates" do
    belongs_to :location, Location
    field :resolution, :string
    field :quantity, :string
    field :unit, :string
    field :measured_at, :utc_datetime
    field :average, :decimal
    field :min, :decimal
    field :max, :decimal
    field :stddev, :decimal
    field :count, :integer
  end

  @doc false
  def changeset(sensor_measurement_aggregate, attrs) do
    sensor_measurement_aggregate
    |> cast(attrs, [:measured_at, :resolution, :quantity, :unit, :location_id, :average, :min, :max, :stddev, :count])
    |> foreign_key_constraint(:location_id)
    |> validate_required([:measured_at, :resolution, :quantity, :unit, :location_id, :average, :min, :max, :stddev, :count])
  end
end
