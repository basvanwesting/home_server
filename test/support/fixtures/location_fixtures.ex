defmodule HomeServer.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeServer.Locations` context.
  """

  alias HomeServer.Locations

  def location_fixture(attrs \\ %{})

  def location_fixture(%{user_id: user_id} = attrs) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        name: "some name"
      })
      |> Locations.create_location()

    location
  end

  def location_fixture(attrs) do
    %{id: user_id} = _user = HomeServer.Factory.insert(:user)
    location_fixture(Map.put(attrs, :user_id, user_id))
  end
end
