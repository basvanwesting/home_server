defmodule HomeServer.Repo.Migrations.ChangeSensorMeasurementsLocationStringToReference do
  use Ecto.Migration

  def change do
    alter table(:sensor_measurements) do
      remove :location, :string
      add :location_id, references(:locations, on_delete: :nilify_all)
    end

    create index(:sensor_measurements, [:location_id])
  end
end
