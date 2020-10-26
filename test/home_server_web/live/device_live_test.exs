defmodule HomeServerWeb.DeviceLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  import HomeServer.DevicesFixtures
  import HomeServer.AccountsFixtures

  @create_attrs %{identifier: "some identifier"}
  @update_attrs %{identifier: "some updated identifier"}
  @invalid_attrs %{identifier: nil}

  defp create_user_and_device(_) do
    %{id: user_id} = user = user_fixture()
    %{id: _device_id} = device = device_fixture(%{user_id: user_id})

    %{device: device, user: user}
  end

  describe "Index" do
    setup [:create_user_and_device]

    test "lists all devices", %{conn: conn, device: device, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Listing Devices"
      assert html =~ device.identifier
    end

    test "saves new device", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("a", "New Device") |> render_click() =~
               "New Device"

      assert_patch(index_live, Routes.device_index_path(conn, :new))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device created successfully"
      assert html =~ "some identifier"
    end

    test "updates device in listing", %{conn: conn, device: device, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(index_live, Routes.device_index_path(conn, :edit, device))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated identifier"
    end

    test "deletes device in listing", %{conn: conn, device: device, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#device-#{device.id}")
    end
  end

  describe "Show" do
    setup [:create_user_and_device]

    test "displays device", %{conn: conn, device: device, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Show Device"
      assert html =~ device.identifier
    end

    test "updates device within modal", %{conn: conn, device: device, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, show_live, _html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(show_live, Routes.device_show_path(conn, :edit, device))

      assert show_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated identifier"
    end
  end
end
