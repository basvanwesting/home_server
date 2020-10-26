defmodule HomeServerWeb.SensorMeasurementLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  import HomeServer.AccountsFixtures
  import HomeServer.SensorMeasurementsFixtures

  defp create_user(_) do
    %{id: _user_id} = user = user_fixture()
    %{user: user}
  end

  defp create_sensor_measurement(_) do
    %{id: _sensor_measurement_id} = sensor_measurement = sensor_measurement_fixture()
    %{sensor_measurement: sensor_measurement}
  end

  describe "Index" do
    setup [:create_user, :create_sensor_measurement]

    test "lists all sensor_measurements", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert html =~ "Listing Sensor measurements"
      assert html =~ sensor_measurement.sensor
    end
  end

  describe "Show" do
    setup [:create_user, :create_sensor_measurement]

    test "displays sensor_measurement", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, Routes.sensor_measurement_show_path(conn, :show, sensor_measurement))

      assert html =~ "Show Sensor measurement"
      assert html =~ sensor_measurement.sensor
    end
  end
end
