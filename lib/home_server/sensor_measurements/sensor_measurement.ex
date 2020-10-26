defmodule HomeServer.SensorMeasurements.SensorMeasurement do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.Locations.Location
  alias HomeServer.Devices

  schema "sensor_measurements" do
    field :host, :string
    field :sensor, :string
    field :measured_at, :utc_datetime
    field :quantity, :string
    field :value, :decimal
    field :unit, :string
    belongs_to :location, Location
  end

  @doc false
  def changeset(sensor_measurement, attrs) do
    sensor_measurement
    |> cast(attrs, [:measured_at, :quantity, :value, :unit, :host, :sensor, :location_id])
    |> enrich_location_id()
    |> foreign_key_constraint(:location_id)
    |> validate_required([:measured_at, :quantity, :value, :unit, :host, :sensor])
  end

  def enrich_location_id(%Ecto.Changeset{changes: %{location_id: location_id}} = changeset) when is_integer(location_id), do: changeset
  def enrich_location_id(%Ecto.Changeset{changes: %{host: host}} = changeset) do
    case Devices.get_location_id_for_host(host) do
      nil         -> changeset
      location_id -> put_change(changeset, :location_id, location_id)
    end
  end
  def enrich_location_id(changeset), do: changeset

end
