defmodule HomeServer.Repo.Migrations.ConvertSensorMeasurementsDecimalToFloat do
  use Ecto.Migration

  def up do
    alter table(:sensor_measurement_aggregates) do
      modify :average, :float, null: false
      modify :min, :float, null: false
      modify :max, :float, null: false
      modify :stddev, :float, null: false
    end

    alter table(:sensor_measurements) do
      modify :value, :float, null: false
    end
  end

  def down do
    alter table(:sensor_measurement_aggregates) do
      modify :average, :decimal, null: false
      modify :min, :decimal, null: false
      modify :max, :decimal, null: false
      modify :stddev, :decimal, null: false
    end

    alter table(:sensor_measurements) do
      modify :value, :decimal, null: false
    end
  end
end
