defmodule HomeServerWeb.DeviceLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  import HomeServer.AccountsFixtures

  @create_attrs %{identifier: "some identifier"}
  @update_attrs %{identifier: "some updated identifier"}
  @invalid_attrs %{identifier: nil}

  defp create_user_and_device(_) do
    %{id: user_id} = user = user_fixture()
    device = Factory.insert(:device, user_id: user_id)

    %{device: device, user: user}
  end

  defp log_in_user(%{conn: conn, user: user}) do
    %{conn: log_in_user(conn, user)}
  end

  describe "Index" do
    setup [:create_user_and_device, :log_in_user]

    test "lists all devices", %{conn: conn, device: device} do
      {:ok, _view, html} = live(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Listing Devices"
      assert html =~ device.identifier
    end

    test "saves new device", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.device_index_path(conn, :index))

      view
      |> element("a", "New Device")
      |> render_click()

      assert_patch(view, Routes.device_index_path(conn, :new))

      view
      |> form("#device-form", device: @invalid_attrs)
      |> render_change()

      assert has_element?(view, "#device-form", "can't be blank")

      {:ok, _, html} =
        view
        |> form("#device-form", device: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device created successfully"
      assert html =~ "some identifier"
    end

    test "updates device in listing", %{conn: conn, device: device} do
      {:ok, view, _html} = live(conn, Routes.device_index_path(conn, :index))

      view
      |> element("#device-#{device.id} a", "Edit")
      |> render_click()

      assert_patch(view, Routes.device_index_path(conn, :edit, device))

      view
      |> form("#device-form", device: @invalid_attrs)
      |> render_change()

      assert has_element?(view, "#device-form", "can't be blank")

      {:ok, _, html} =
        view
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated identifier"
    end

    test "deletes device in listing", %{conn: conn, device: device} do
      {:ok, view, _html} = live(conn, Routes.device_index_path(conn, :index))

      view
      |> element("#device-#{device.id} a", "Delete")
      |> render_click()

      refute has_element?(view, "#device-#{device.id}")
    end
  end

  describe "Show" do
    setup [:create_user_and_device, :log_in_user]

    test "displays device", %{conn: conn, device: device} do
      {:ok, _view, html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Show Device"
      assert html =~ device.identifier
    end

    test "updates device within modal", %{conn: conn, device: device} do
      {:ok, view, _html} = live(conn, Routes.device_show_path(conn, :show, device))

      view
      |> element("a", "Edit")
      |> render_click()

      assert_patch(view, Routes.device_show_path(conn, :edit, device))

      view
      |> form("#device-form", device: @invalid_attrs)
      |> render_change()

      assert has_element?(view, "#device-form", "can't be blank")

      {:ok, _, html} =
        view
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated identifier"
    end
  end
end
