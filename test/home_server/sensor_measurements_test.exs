defmodule HomeServer.SensorMeasurementsTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurements

  describe "sensor_measurements" do
    alias HomeServer.SensorMeasurements.SensorMeasurement

    @valid_attrs %{location: "some location", measured_at: "2010-04-17T14:00:00Z", quantity: "some quantity", host: "some host", unit: "some unit", value: "120.5", sensor: "some sensor"}
    @update_attrs %{location: "some updated location", measured_at: "2011-05-18T15:01:01Z", quantity: "some updated quantity", host: "some updated host", unit: "some updated unit", value: "456.7", sensor: "some updated sensor"}
    @invalid_attrs %{location: nil, measured_at: nil, quantity: nil, host: nil, unit: nil, value: nil, sensor: nil}

    def sensor_measurement_fixture(attrs \\ %{}) do
      {:ok, sensor_measurement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SensorMeasurements.create_sensor_measurement()

      sensor_measurement
    end

    test "list_sensor_measurements/0 returns all sensor_measurements" do
      sensor_measurement = sensor_measurement_fixture()
      assert SensorMeasurements.list_sensor_measurements() == [sensor_measurement]
    end

    test "get_sensor_measurement!/1 returns the sensor_measurement with given id" do
      sensor_measurement = sensor_measurement_fixture()
      assert SensorMeasurements.get_sensor_measurement!(sensor_measurement.id) == sensor_measurement
    end

    test "create_sensor_measurement/1 with valid data creates a sensor_measurement" do
      assert {:ok, %SensorMeasurement{} = sensor_measurement} = SensorMeasurements.create_sensor_measurement(@valid_attrs)
      assert sensor_measurement.location == "some location"
      assert sensor_measurement.measured_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert sensor_measurement.host == "some host"
      assert sensor_measurement.sensor == "some sensor"
      assert sensor_measurement.quantity == "some quantity"
      assert sensor_measurement.unit == "some unit"
      assert sensor_measurement.value == Decimal.new("120.5")
    end

    test "create_sensor_measurement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SensorMeasurements.create_sensor_measurement(@invalid_attrs)
    end

    test "update_sensor_measurement/2 with valid data updates the sensor_measurement" do
      sensor_measurement = sensor_measurement_fixture()
      assert {:ok, %SensorMeasurement{} = sensor_measurement} = SensorMeasurements.update_sensor_measurement(sensor_measurement, @update_attrs)
      assert sensor_measurement.location == "some updated location"
      assert sensor_measurement.measured_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert sensor_measurement.host == "some updated host"
      assert sensor_measurement.sensor == "some updated sensor"
      assert sensor_measurement.quantity == "some updated quantity"
      assert sensor_measurement.unit == "some updated unit"
      assert sensor_measurement.value == Decimal.new("456.7")
    end

    test "update_sensor_measurement/2 with invalid data returns error changeset" do
      sensor_measurement = sensor_measurement_fixture()
      assert {:error, %Ecto.Changeset{}} = SensorMeasurements.update_sensor_measurement(sensor_measurement, @invalid_attrs)
      assert sensor_measurement == SensorMeasurements.get_sensor_measurement!(sensor_measurement.id)
    end

    test "delete_sensor_measurement/1 deletes the sensor_measurement" do
      sensor_measurement = sensor_measurement_fixture()
      assert {:ok, %SensorMeasurement{}} = SensorMeasurements.delete_sensor_measurement(sensor_measurement)
      assert_raise Ecto.NoResultsError, fn -> SensorMeasurements.get_sensor_measurement!(sensor_measurement.id) end
    end

    test "change_sensor_measurement/1 returns a sensor_measurement changeset" do
      sensor_measurement = sensor_measurement_fixture()
      assert %Ecto.Changeset{} = SensorMeasurements.change_sensor_measurement(sensor_measurement)
    end
  end
end
