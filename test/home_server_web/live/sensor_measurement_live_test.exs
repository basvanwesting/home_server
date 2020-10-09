defmodule HomeServerWeb.SensorMeasurementLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  import HomeServer.AccountsFixtures
  import HomeServer.SensorMeasurementsFixtures

  @create_attrs %{location: "some location", measured_at: "2010-04-17T14:00:00Z", quantity: "some quantity", host: "some host", unit: "some unit", value: "120.5", sensor: "some sensor"}
  @update_attrs %{location: "some updated location", measured_at: "2011-05-18T15:01:01Z", quantity: "some updated quantity", host: "some updated host", unit: "some updated unit", value: "456.7", sensor: "some updated sensor"}
  @invalid_attrs %{location: nil, measured_at: nil, quantity: nil, host: nil, unit: nil, value: nil, sensor: nil}

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
      assert html =~ sensor_measurement.location
    end

    test "saves new sensor_measurement", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert index_live |> element("a", "New Sensor measurement") |> render_click() =~
               "New Sensor measurement"

      assert_patch(index_live, Routes.sensor_measurement_index_path(conn, :new))

      assert index_live
             |> form("#sensor_measurement-form", sensor_measurement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sensor_measurement-form", sensor_measurement: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert html =~ "Sensor measurement created successfully"
      assert html =~ "some location"
    end

    test "updates sensor_measurement in listing", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert index_live |> element("#sensor_measurement-#{sensor_measurement.id} a", "Edit") |> render_click() =~
               "Edit Sensor measurement"

      assert_patch(index_live, Routes.sensor_measurement_index_path(conn, :edit, sensor_measurement))

      assert index_live
             |> form("#sensor_measurement-form", sensor_measurement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sensor_measurement-form", sensor_measurement: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert html =~ "Sensor measurement updated successfully"
      assert html =~ "some updated location"
    end

    test "deletes sensor_measurement in listing", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.sensor_measurement_index_path(conn, :index))

      assert index_live |> element("#sensor_measurement-#{sensor_measurement.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sensor_measurement-#{sensor_measurement.id}:hidden")
    end
  end

  describe "Show" do
    setup [:create_user, :create_sensor_measurement]

    test "displays sensor_measurement", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, Routes.sensor_measurement_show_path(conn, :show, sensor_measurement))

      assert html =~ "Show Sensor measurement"
      assert html =~ sensor_measurement.location
    end

    test "updates sensor_measurement within modal", %{conn: conn, user: user, sensor_measurement: sensor_measurement} do
      conn = conn |> log_in_user(user)
      {:ok, show_live, _html} = live(conn, Routes.sensor_measurement_show_path(conn, :show, sensor_measurement))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sensor measurement"

      assert_patch(show_live, Routes.sensor_measurement_show_path(conn, :edit, sensor_measurement))

      assert show_live
             |> form("#sensor_measurement-form", sensor_measurement: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#sensor_measurement-form", sensor_measurement: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sensor_measurement_show_path(conn, :show, sensor_measurement))

      assert html =~ "Sensor measurement updated successfully"
      assert html =~ "some updated location"
    end
  end
end
