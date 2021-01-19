defmodule HomeServerWeb.SensorMeasurementAggregateLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  import HomeServer.LocationsFixtures
  import HomeServer.SensorMeasurementAggregatesFixtures

  defp create_user(_) do
    %{id: _user_id} = user = Factory.insert(:user)
    %{user: user}
  end

  defp create_sensor_measurement_aggregate(_) do
    %{id: location_id} = location_fixture()

    %{id: _sensor_measurement_aggregate_id} =
      sensor_measurement_aggregate =
      sensor_measurement_aggregate_fixture(%{location_id: location_id})

    %{sensor_measurement_aggregate: sensor_measurement_aggregate}
  end

  describe "Index" do
    setup [:create_user, :create_sensor_measurement_aggregate]

    test "lists all sensor_measurement_aggregates", %{
      conn: conn,
      user: user,
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      conn = conn |> log_in_user(user)

      {:ok, _index_live, html} =
        live(conn, Routes.sensor_measurement_aggregate_index_path(conn, :index))

      assert html =~ "Listing Sensor Measurement Aggregates"
      assert html =~ sensor_measurement_aggregate.quantity
    end
  end

  describe "Show" do
    setup [:create_user, :create_sensor_measurement_aggregate]

    test "displays sensor_measurement_aggregate", %{
      conn: conn,
      user: user,
      sensor_measurement_aggregate: sensor_measurement_aggregate
    } do
      conn = conn |> log_in_user(user)

      {:ok, _show_live, html} =
        live(
          conn,
          Routes.sensor_measurement_aggregate_show_path(conn, :show, sensor_measurement_aggregate)
        )

      assert html =~ "Show Sensor Measurement Aggregate"
      assert html =~ sensor_measurement_aggregate.quantity
    end
  end
end
