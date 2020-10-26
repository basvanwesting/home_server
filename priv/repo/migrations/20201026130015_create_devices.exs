defmodule HomeServer.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :identifier, :string
      add :user_id, references(:users, on_delete: :nilify_all)
      add :location_id, references(:locations, on_delete: :nilify_all)

      timestamps()
    end

    create index(:devices, [:identifier])
    create index(:devices, [:user_id])
    create index(:devices, [:location_id])
  end
end
