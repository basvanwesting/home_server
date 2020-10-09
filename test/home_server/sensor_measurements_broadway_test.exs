defmodule HomeServer.SensorMeasurementsBroadwayTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementsBroadway
  alias HomeServer.SensorMeasurements
  alias HomeServer.SensorMeasurements.SensorMeasurement

  describe "sensor_measurements" do

    #@valid_message "{\"location\":\"Office\",\"measured_at\":\"2020-10-08T14:53:44.669156Z\",\"quantity\":\"CO2\",\"host\":\"some host\",\"unit\":\"ppm\",\"value\":428}"
    @valid_message "{\"location\":\"Office\",\"measured_at\":\"2020-10-08T14:53:44Z\",\"quantity\":\"CO2\",\"host\":\"localhost\",\"unit\":\"ppm\",\"value\":428,\"sensor\":\"A0\"}"

    test "test message" do
      ref = Broadway.test_message(SensorMeasurementsBroadway, @valid_message)
      :timer.sleep(500)
      assert_receive {:ack, ^ref, [%{data: @valid_message}], []}

      [sensor_measurement] = SensorMeasurements.list_sensor_measurements()
      assert %SensorMeasurement{} = sensor_measurement
      assert sensor_measurement.location    == "Office"
      assert sensor_measurement.measured_at == DateTime.from_naive!(~N[2020-10-08T14:53:44Z], "Etc/UTC")
      assert sensor_measurement.host        == "localhost"
      assert sensor_measurement.sensor      == "A0"
      assert sensor_measurement.quantity    == "CO2"
      assert sensor_measurement.unit        == "ppm"
      assert sensor_measurement.value       == Decimal.new("428")
    end
  end

end

