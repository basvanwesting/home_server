defmodule HomeServer.Repo.Migrations.CreateSensorMeasurements do
  use Ecto.Migration

  def change do
    create table(:sensor_measurements) do
      add :measured_at, :utc_datetime
      add :location, :string
      add :quantity, :string
      add :value, :decimal
      add :unit, :string
      add :source, :string
    end

    create index(:sensor_measurements, [:measured_at, :location, :quantity])
  end
end
