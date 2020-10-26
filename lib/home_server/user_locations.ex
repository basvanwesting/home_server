defmodule HomeServer.UserLocations do
  @moduledoc """
  The Locations context as seen from the to the mandatory belongs_to user
  """

  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.Locations.Location
  alias HomeServer.Accounts.User

  @spec list_locations(User.t()) :: [Location.t()]
  def list_locations(%User{} = user) do
    Repo.all(
      from e in Location,
      where: e.user_id == ^user.id
    )
  end

  @spec get_location!(non_neg_integer | binary, User.t()) :: Location.t()
  def get_location!(id, %User{} = user) do
    Repo.get_by!(Location, id: id, user_id: user.id)
  end

  def create_location(attrs \\ %{}, %User{} = user) do
    build_location(attrs, user)
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Ecto.Changeset.delete_change(:user_id)
    |> Repo.update()
  end

  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  def change_location(%Location{} = location, attrs \\ %{}, %User{} = user) do
    Location.changeset(location, attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
  end

  def build_location(attrs \\ %{}, %User{} = user) do
    Ecto.build_assoc(user, :locations, attrs)
  end

end
