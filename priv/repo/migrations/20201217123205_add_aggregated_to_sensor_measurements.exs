defmodule HomeServer.Repo.Migrations.AddAggregatedToSensorMeasurements do
  use Ecto.Migration

  def change do
    alter table(:sensor_measurements) do
      add :aggregated, :boolean, default: false
    end
  end
end
