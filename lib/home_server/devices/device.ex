defmodule HomeServer.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.Accounts.User
  alias HomeServer.Locations.Location

  @type t :: %__MODULE__{
          id: non_neg_integer | nil,
          identifier: binary | nil,
          user: User.t() | nil | Ecto.Association.NotLoaded.t(),
          location: Location.t() | nil | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "devices" do
    field :identifier, :string
    belongs_to :user, User
    belongs_to :location, Location

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:identifier, :user_id, :location_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:location_id)
    |> validate_required([:identifier])
  end
end
