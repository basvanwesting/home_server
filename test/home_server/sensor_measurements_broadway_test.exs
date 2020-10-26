defmodule HomeServer.SensorMeasurementsBroadwayTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementsBroadway
  alias HomeServer.SensorMeasurements
  alias HomeServer.SensorMeasurements.SensorMeasurement

  describe "sensor_measurements" do

    @valid_message "{\"measured_at\":\"2020-10-08T14:53:44Z\",\"quantity\":\"CO2\",\"host\":\"localhost\",\"unit\":\"ppm\",\"value\":428,\"sensor\":\"A0\"}"
    #@invalid_message "{\"junk\":\"foobar\"}"

    test "test valid message" do
      ref = Broadway.test_message(SensorMeasurementsBroadway, @valid_message)
      assert_receive {:ack, ^ref, [%{data: @valid_message}], []}
    end

    test "handle_message/3" do
      SensorMeasurementsBroadway.handle_message(nil, %{data: @valid_message}, nil)

      [sensor_measurement] = SensorMeasurements.list_sensor_measurements()
      assert %SensorMeasurement{} = sensor_measurement
      assert sensor_measurement.measured_at == DateTime.from_naive!(~N[2020-10-08T14:53:44Z], "Etc/UTC")
      assert sensor_measurement.host        == "localhost"
      assert sensor_measurement.sensor      == "A0"
      assert sensor_measurement.quantity    == "CO2"
      assert sensor_measurement.unit        == "ppm"
      assert sensor_measurement.value       == Decimal.new("428")
    end
  end

end

