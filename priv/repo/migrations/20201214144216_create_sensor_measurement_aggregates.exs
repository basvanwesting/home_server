defmodule HomeServer.Repo.Migrations.CreateSensorMeasurementAggregates do
  use Ecto.Migration

  def change do
    create table(:sensor_measurement_aggregates) do
      add :location_id, references(:locations, on_delete: :nilify_all)
      add :resolution, :string
      add :quantity, :string
      add :unit, :string
      add :measured_at, :utc_datetime
      add :average, :decimal
      add :min, :decimal
      add :max, :decimal
      add :stddev, :decimal
      add :count, :integer
    end

    create index(:sensor_measurement_aggregates, [:location_id, :resolution, :quantity, :unit, :measured_at])
  end
end
