defmodule HomeServer.Repo.Migrations.CreateSensorMeasurementAggregates do
  use Ecto.Migration

  def change do
    create table(:sensor_measurement_aggregates) do
      add :location_id, references(:locations, on_delete: :delete_all)
      add :resolution, :string, null: false
      add :quantity, :string, null: false
      add :unit, :string, null: false
      add :measured_at, :utc_datetime, null: false
      add :average, :decimal, null: false
      add :min, :decimal, null: false
      add :max, :decimal, null: false
      add :stddev, :decimal, null: false
      add :count, :integer, null: false
    end

    create unique_index(:sensor_measurement_aggregates, [
             :location_id,
             :resolution,
             :quantity,
             :unit,
             :measured_at
           ])
  end
end
