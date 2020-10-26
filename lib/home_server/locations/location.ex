defmodule HomeServer.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  alias HomeServer.Accounts.User

  @type t :: %__MODULE__{
      id: non_neg_integer | nil,
      user: User.t() | nil | Ecto.Association.NotLoaded.t(),
      name: binary | nil,
      inserted_at: NaiveDateTime.t() | nil,
      updated_at: NaiveDateTime.t() | nil,
    }

  schema "locations" do
    belongs_to :user, User
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:name, :user_id])
  end
end
