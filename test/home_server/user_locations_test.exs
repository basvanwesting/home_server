defmodule HomeServer.UserLocationsTest do
  use HomeServer.DataCase

  alias HomeServer.UserLocations
  alias HomeServer.Locations.Location

  @valid_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_user(_context) do
    user = Factory.insert(:user)
    %{user: user}
  end

  defp create_location(context) do
    location = Factory.insert(:location, user: context.user) |> Factory.forget(:user)
    %{location: location}
  end

  describe "locations" do
    setup [:create_user]

    test "list_locations/1 returns all locations", %{user: user} do
      location = Factory.insert(:location, user: user) |> Factory.forget(:user)
      other_location = Factory.insert(:location, user: user) |> Factory.forget(:user)
      _other_location_for_other_user = Factory.insert(:location)

      assert MapSet.new(UserLocations.list_locations(user)) ==
               MapSet.new([location, other_location])
    end

    test "create_location/1 with valid data creates a location", %{user: user} do
      assert {:ok, %Location{} = location} = UserLocations.create_location(@valid_attrs, user)
      assert location.name == "some name"
      assert location.user_id == user.id

      location = location |> HomeServer.Repo.preload(:user)
      assert location.user == user
    end

    test "create_location/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = UserLocations.create_location(@invalid_attrs, user)
    end
  end

  describe "existing location" do
    setup [:create_user, :create_location]

    test "get_location/2 returns the location with given id", %{user: user, location: location} do
      assert UserLocations.get_location!(location.id, user) == location
    end

    test "update_location/2 with valid data updates the location", %{location: location} do
      assert {:ok, %Location{} = location} =
               UserLocations.update_location(location, @update_attrs)

      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset", %{user: user, location: location} do
      assert {:error, %Ecto.Changeset{}} = UserLocations.update_location(location, @invalid_attrs)
      assert location == UserLocations.get_location!(location.id, user)
    end

    test "delete_location/1 deletes the location", %{user: user, location: location} do
      assert {:ok, %Location{}} = UserLocations.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> UserLocations.get_location!(location.id, user) end
    end

    test "change_location/2 returns a location changeset", %{user: user, location: location} do
      assert %Ecto.Changeset{} = UserLocations.change_location(location, user)
    end
  end
end
