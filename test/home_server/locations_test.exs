defmodule HomeServer.LocationsTest do
  use HomeServer.DataCase

  alias HomeServer.Locations
  import HomeServer.LocationsFixtures
  import HomeServer.AccountsFixtures

  describe "locations" do
    alias HomeServer.Locations.Location

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Locations.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Locations.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      %{id: user_id} = user = user_fixture()

      assert {:ok, %Location{} = location} =
               Locations.create_location(Map.put(@valid_attrs, :user_id, user_id))

      assert location.name == "some name"
      assert location.user_id == user_id

      location = location |> HomeServer.Repo.preload(:user)
      assert location.user == user
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locations.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = Locations.update_location(location, @update_attrs)
      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_location(location, @invalid_attrs)
      assert location == Locations.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Locations.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Locations.change_location(location)
    end

    test "location_topic" do
      location = location_fixture()

      assert Locations.location_topic(1) == "location:1"
      assert Locations.location_topic(%{location_id: 1}) == "location:1"
      assert Locations.location_topic(location) == "location:#{location.id}"
    end
  end
end
