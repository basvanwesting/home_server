defmodule HomeServerWeb.PageLiveTest do
  use HomeServerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Home Server"
    assert render(page_live) =~ "Welcome to Home Server"
  end
end
