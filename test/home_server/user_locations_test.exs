defmodule HomeServer.UserLocationsTest do
  use HomeServer.DataCase

  alias HomeServer.UserLocations
  import HomeServer.LocationsFixtures

  describe "locations" do
    alias HomeServer.Locations.Location

    @update_attrs %{name: "some updated name"}
    @valid_attrs %{name: "some name"}
    @invalid_attrs %{name: nil}

    test "list_locations/1 returns all locations" do
      %{id: user_id} = user = Factory.insert(:user)
      location = location_fixture(%{user_id: user_id})
      other_location = location_fixture(%{user_id: user_id})
      _other_location_for_other_user = location_fixture()

      assert MapSet.new(UserLocations.list_locations(user)) ==
               MapSet.new([location, other_location])
    end

    test "get_location/2 returns the location with given id" do
      %{id: user_id} = user = Factory.insert(:user)
      location = location_fixture(%{user_id: user_id})
      assert UserLocations.get_location!(location.id, user) == location
    end

    test "create_location/1 with valid data creates a location" do
      %{id: user_id} = user = Factory.insert(:user)
      assert {:ok, %Location{} = location} = UserLocations.create_location(@valid_attrs, user)
      assert location.name == "some name"
      assert location.user_id == user_id

      location = location |> HomeServer.Repo.preload(:user)
      assert location.user == user
    end

    test "create_location/1 with invalid data returns error changeset" do
      %{id: _user_id} = user = Factory.insert(:user)
      assert {:error, %Ecto.Changeset{}} = UserLocations.create_location(@invalid_attrs, user)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()

      assert {:ok, %Location{} = location} =
               UserLocations.update_location(location, @update_attrs)

      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      %{id: user_id} = user = Factory.insert(:user)
      location = location_fixture(%{user_id: user_id})
      assert {:error, %Ecto.Changeset{}} = UserLocations.update_location(location, @invalid_attrs)
      assert location == UserLocations.get_location!(location.id, user)
    end

    test "delete_location/1 deletes the location" do
      %{id: user_id} = user = Factory.insert(:user)
      location = location_fixture(%{user_id: user_id})
      assert {:ok, %Location{}} = UserLocations.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> UserLocations.get_location!(location.id, user) end
    end

    test "change_location/2 returns a location changeset" do
      %{id: user_id} = user = Factory.insert(:user)
      location = location_fixture(%{user_id: user_id})
      assert %Ecto.Changeset{} = UserLocations.change_location(location, user)
    end
  end
end
