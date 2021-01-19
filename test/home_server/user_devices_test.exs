defmodule HomeServer.UserDevicesTest do
  use HomeServer.DataCase

  alias HomeServer.UserDevices

  describe "devices" do
    alias HomeServer.Devices.Device

    @valid_attrs %{identifier: "some identifier"}
    @update_attrs %{identifier: "some updated identifier"}
    @invalid_attrs %{identifier: nil}

    test "list_devices/1 returns all devices" do
      %{id: user_id} = user = Factory.insert(:user)
      device = Factory.insert(:device, user_id: user_id)
      other_device = Factory.insert(:device, user_id: user_id)
      _other_device_for_other_user = Factory.insert(:device)
      assert MapSet.new(UserDevices.list_devices(user)) == MapSet.new([device, other_device])
    end

    test "get_device/2 returns the device with given id" do
      %{id: user_id} = user = Factory.insert(:user)
      device = Factory.insert(:device, user_id: user_id)
      assert UserDevices.get_device!(device.id, user) == device
    end

    test "create_device/1 with valid data creates a device" do
      %{id: user_id} = user = Factory.insert(:user)
      assert {:ok, %Device{} = device} = UserDevices.create_device(@valid_attrs, user)
      assert device.identifier == "some identifier"
      assert device.user_id == user_id

      device = device |> HomeServer.Repo.preload(:user)
      assert device.user == user
    end

    test "create_device/1 with invalid data returns error changeset" do
      %{id: _user_id} = user = Factory.insert(:user)
      assert {:error, %Ecto.Changeset{}} = UserDevices.create_device(@invalid_attrs, user)
    end

    test "update_device/2 with valid data updates the device" do
      device = Factory.insert(:device)
      assert {:ok, %Device{} = device} = UserDevices.update_device(device, @update_attrs)
      assert device.identifier == "some updated identifier"
    end

    test "update_device/2 with invalid data returns error changeset" do
      %{id: user_id} = user = Factory.insert(:user)
      device = Factory.insert(:device, user_id: user_id)
      assert {:error, %Ecto.Changeset{}} = UserDevices.update_device(device, @invalid_attrs)
      assert device == UserDevices.get_device!(device.id, user)
    end

    test "delete_device/1 deletes the device" do
      %{id: user_id} = user = Factory.insert(:user)
      device = Factory.insert(:device, user_id: user_id)
      assert {:ok, %Device{}} = UserDevices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> UserDevices.get_device!(device.id, user) end
    end

    test "change_device/2 returns a device changeset" do
      %{id: user_id} = user = Factory.insert(:user)
      device = Factory.insert(:device, user_id: user_id)
      assert %Ecto.Changeset{} = UserDevices.change_device(device, user)
    end
  end
end
