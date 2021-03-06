defmodule HomeServer.DevicesTest do
  use HomeServer.DataCase

  alias HomeServer.Devices

  describe "devices" do
    alias HomeServer.Devices.Device

    @valid_attrs %{identifier: "some identifier"}
    @update_attrs %{identifier: "some updated identifier"}
    @invalid_attrs %{identifier: nil}

    test "list_devices/0 returns all devices" do
      device = Factory.insert(:device)
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = Factory.insert(:device)
      assert Devices.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      assert {:ok, %Device{} = device} = Devices.create_device(@valid_attrs)
      assert device.identifier == "some identifier"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = Factory.insert(:device)
      assert {:ok, %Device{} = device} = Devices.update_device(device, @update_attrs)
      assert device.identifier == "some updated identifier"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = Factory.insert(:device)
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = Factory.insert(:device)
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = Factory.insert(:device)
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end

    test "get_location_id_for_host/1" do
       location = Factory.insert(:location)
      _device = Factory.insert(:device, location_id: location.id, identifier: "1234")

      assert location.id == Devices.get_location_id_for_host("nerves-1234")
      assert location.id == Devices.get_location_id_for_host("1234")
      assert nil == Devices.get_location_id_for_host("foobar")
      assert nil == Devices.get_location_id_for_host(nil)
    end
  end
end
