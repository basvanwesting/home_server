defmodule HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey
  alias HomeServer.Locations.Location

  @type t :: %__MODULE__{
          location_id: non_neg_integer,
          resolution: binary,
          quantity: binary,
          unit: binary,
          measured_at: UtcDateTime.t(),
          average: float,
          min: float,
          max: float,
          stddev: float,
          count: non_neg_integer
        }

  schema "sensor_measurement_aggregates" do
    belongs_to :location, Location
    field :resolution, :string
    field :quantity, :string
    field :unit, :string
    field :measured_at, :utc_datetime
    field :average, :float
    field :min, :float
    field :max, :float
    field :stddev, :float
    field :count, :integer
  end

  @doc false
  def changeset(sensor_measurement_aggregate, attrs) do
    sensor_measurement_aggregate
    |> cast(attrs, [
      :measured_at,
      :resolution,
      :quantity,
      :unit,
      :location_id,
      :average,
      :min,
      :max,
      :stddev,
      :count
    ])
    |> foreign_key_constraint(:location_id)
    |> unique_constraint([:location_id, :resolution, :quantity, :unit, :measured_at])
    |> validate_required([
      :measured_at,
      :resolution,
      :quantity,
      :unit,
      :location_id,
      :average,
      :min,
      :max,
      :stddev,
      :count
    ])
  end

  def factory(%SensorMeasurementAggregateKey{} = key) do
    struct(__MODULE__, Map.from_struct(key))
  end
end
