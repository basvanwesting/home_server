defmodule HomeServer.SensorMeasurementsBroadwayTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementsBroadway
  alias HomeServer.SensorMeasurements
  alias HomeServer.SensorMeasurements.SensorMeasurement

  describe "sensor_measurements" do
    @valid_message "{\"measured_at\":\"2020-10-08T14:53:44Z\",\"quantity\":\"CO2\",\"host\":\"localhost\",\"unit\":\"ppm\",\"value\":428,\"sensor\":\"A0\",\"unknown_field\":\"ignored\"}"
    @invalid_message "{\"junk\":\"foobar\"}"

    test "test valid message" do
      ref = Broadway.test_message(SensorMeasurementsBroadway, @valid_message)
      assert_receive {:ack, ^ref, [%{status: :ok}], []}
      # assert_receive {:ack, ^ref, [%{data: @valid_message}], []}
    end

    @tag :skip
    test "test invalid message" do
      ref = Broadway.test_message(SensorMeasurementsBroadway, @invalid_message)
      assert_receive {:ack, ^ref, [], [%{status: {:failed, reason}}]}

      assert reason == %{
               host: ["can't be blank"],
               measured_at: ["can't be blank"],
               quantity: ["can't be blank"],
               sensor: ["can't be blank"],
               unit: ["can't be blank"],
               value: ["can't be blank"]
             }
    end

    @tag :skip
    test "test unparsable message" do
      ref = Broadway.test_message(SensorMeasurementsBroadway, "not a map")
      assert_receive {:ack, ^ref, [], [%{status: {:failed, reason}}]}
      assert %Jason.DecodeError{} = reason
    end

    test "handle_message/3" do
      SensorMeasurementsBroadway.handle_message(nil, %{data: @valid_message}, nil)

      [sensor_measurement] = SensorMeasurements.list_sensor_measurements()
      assert %SensorMeasurement{} = sensor_measurement

      assert sensor_measurement.measured_at ==
               DateTime.from_naive!(~N[2020-10-08T14:53:44Z], "Etc/UTC")

      assert sensor_measurement.host == "localhost"
      assert sensor_measurement.sensor == "A0"
      assert sensor_measurement.quantity == "CO2"
      assert sensor_measurement.unit == "ppm"
      assert sensor_measurement.value == 428
    end
  end
end
