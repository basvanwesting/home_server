defmodule HomeServer.SensorMeasurementAggregatesTest do
  use HomeServer.DataCase

  alias HomeServer.SensorMeasurementAggregates
  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregateKey

  setup do
    location = Factory.insert(:location)

    sensor_measurement_aggregate =
      Factory.insert(:sensor_measurement_aggregate, location_id: location.id)

    %{location: location, sensor_measurement_aggregate: sensor_measurement_aggregate}
  end

  describe "sensor_measurement_aggregates" do
    alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate

    @valid_attrs %{
      measured_at: "2010-04-17T14:00:00Z",
      resolution: "hour",
      quantity: "some quantity",
      unit: "some unit",
      average: "10.0",
      min: "8.0",
      max: "11.0",
      stddev: "1.0",
      count: 10
    }
    @update_attrs %{
      measured_at: "2011-05-18T15:01:01Z",
      resolution: "hour",
      quantity: "some updated quantity",
      unit: "some updated unit",
      average: "10.1",
      min: "8.1",
      max: "11.1",
      stddev: "1.1",
      count: 11
    }
    @invalid_attrs %{measured_at: nil, quantity: nil, unit: nil, average: nil}

    test "list_sensor_measurement_aggregates/0 returns all sensor_measurement_aggregates", %{
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      assert SensorMeasurementAggregates.list_sensor_measurement_aggregates() == [
               sensor_measurement_aggregate
             ]
    end

    test "get_sensor_measurement_aggregate!/1 returns the sensor_measurement_aggregate with given id",
         %{sensor_measurement_aggregate: sensor_measurement_aggregate} do
      assert SensorMeasurementAggregates.get_sensor_measurement_aggregate!(
               sensor_measurement_aggregate.id
             ) == sensor_measurement_aggregate
    end

    test "get_sensor_measurement_aggregate_by_key/1 returns the sensor_measurement_aggregate with given key",
         %{location: location, sensor_measurement_aggregate: sensor_measurement_aggregate} do
      assert SensorMeasurementAggregates.get_sensor_measurement_aggregate_by_key(
               %SensorMeasurementAggregateKey{
                 location_id: location.id,
                 resolution: "hour",
                 quantity: "Temperature",
                 unit: "Celsius",
                 measured_at: sensor_measurement_aggregate.measured_at
               }
             ) == sensor_measurement_aggregate
    end

    test "get_sensor_measurement_aggregate_by_key/1 returns nil with non existing key", %{
      location: location,
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      assert SensorMeasurementAggregates.get_sensor_measurement_aggregate_by_key(
               %SensorMeasurementAggregateKey{
                 location_id: location.id,
                 resolution: "hour",
                 quantity: "CO2",
                 unit: "Celsius",
                 measured_at: sensor_measurement_aggregate.measured_at
               }
             ) == nil
    end

    test "list_sensor_measurement_aggregates_by_keys/1 returns the sensor_measurement_aggregates with given keys",
         %{location: location, sensor_measurement_aggregate: sensor_measurement_aggregate} do
      assert SensorMeasurementAggregates.list_sensor_measurement_aggregates_by_keys([
               %SensorMeasurementAggregateKey{
                 location_id: location.id,
                 resolution: "hour",
                 quantity: "Temperature",
                 unit: "Celsius",
                 measured_at: sensor_measurement_aggregate.measured_at
               }
             ]) == [sensor_measurement_aggregate]
    end

    test "create_sensor_measurement/1 with valid data creates", %{location: location} do
      assert {:ok, %SensorMeasurementAggregate{} = sensor_measurement_aggregate} =
               SensorMeasurementAggregates.create_sensor_measurement_aggregate(
                 Map.merge(@valid_attrs, %{location_id: location.id})
               )

      assert sensor_measurement_aggregate.location_id == location.id
      assert sensor_measurement_aggregate.quantity == "some quantity"
      assert sensor_measurement_aggregate.unit == "some unit"
      assert sensor_measurement_aggregate.average == 10.0
    end

    test "create_sensor_measurement_aggregate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               SensorMeasurementAggregates.create_sensor_measurement_aggregate(@invalid_attrs)
    end

    test "update_sensor_measurement_aggregate/2 with valid data updates the sensor_measurement_aggregate",
         %{sensor_measurement_aggregate: sensor_measurement_aggregate} do
      assert {:ok, %SensorMeasurementAggregate{} = sensor_measurement_aggregate} =
               SensorMeasurementAggregates.update_sensor_measurement_aggregate(
                 sensor_measurement_aggregate,
                 @update_attrs
               )

      assert sensor_measurement_aggregate.measured_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert sensor_measurement_aggregate.quantity == "some updated quantity"
      assert sensor_measurement_aggregate.unit == "some updated unit"
      assert sensor_measurement_aggregate.average == 10.1
    end

    test "update_sensor_measurement_aggregate/2 with invalid data returns error changeset", %{
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      assert {:error, %Ecto.Changeset{}} =
               SensorMeasurementAggregates.update_sensor_measurement_aggregate(
                 sensor_measurement_aggregate,
                 @invalid_attrs
               )

      assert sensor_measurement_aggregate ==
               SensorMeasurementAggregates.get_sensor_measurement_aggregate!(
                 sensor_measurement_aggregate.id
               )
    end

    test "delete_sensor_measurement_aggregate/1 deletes the sensor_measurement_aggregate", %{
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      assert {:ok, %SensorMeasurementAggregate{}} =
               SensorMeasurementAggregates.delete_sensor_measurement_aggregate(
                 sensor_measurement_aggregate
               )

      assert_raise Ecto.NoResultsError, fn ->
        SensorMeasurementAggregates.get_sensor_measurement_aggregate!(
          sensor_measurement_aggregate.id
        )
      end
    end

    test "change_sensor_measurement_aggregate/1 returns a sensor_measurement_aggregate changeset",
         %{sensor_measurement_aggregate: sensor_measurement_aggregate} do
      assert %Ecto.Changeset{} =
               SensorMeasurementAggregates.change_sensor_measurement_aggregate(
                 sensor_measurement_aggregate
               )
    end

    test "sensor_measurement_aggregates_topic" do
      assert SensorMeasurementAggregates.sensor_measurement_aggregates_topic() ==
               "sensor_measurement_aggregates"
    end
  end
end
