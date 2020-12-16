defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.Locations.Location

  @type t :: %__MODULE__{
      location_id: non_neg_integer,
      resolution: binary,
      quantity: binary,
      unit: binary,
      measured_at: UtcDateTime.t(),
      average: Decimal.t(),
      min: Decimal.t(),
      max: Decimal.t(),
      stddev: Decimal.t(),
      count: non_neg_integer,
      variance: Decimal.t() | nil,
    }

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
    field :variance, :decimal, virtual: true
    field :count, :integer
  end

  @doc false
  def changeset(sensor_measurement_aggregate, attrs) do
    sensor_measurement_aggregate
    |> cast(attrs, [:measured_at, :resolution, :quantity, :unit, :location_id, :average, :min, :max, :stddev, :count])
    |> foreign_key_constraint(:location_id)
    |> unique_constraint([:location_id, :resolution, :quantity, :unit, :measured_at])
    |> validate_required([:measured_at, :resolution, :quantity, :unit, :location_id, :average, :min, :max, :stddev, :count])
  end
end
