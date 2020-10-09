defmodule HomeServer.Repo.Migrations.AddSensorToSensorMeasurements do
  use Ecto.Migration

  def change do
    rename table(:sensor_measurements), :source, to: :host
    alter table(:sensor_measurements) do
      add :sensor, :string
    end
  end
end
