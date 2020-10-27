defmodule HomeServerWeb.LocationLive.Show do
  use HomeServerWeb, :live_view

  alias HomeServer.UserLocations
  alias HomeServer.LocationPlotQuery

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location = UserLocations.get_location!(id, socket.assigns.current_user)
    plot_data_headers = LocationPlotQuery.data_headers(location.id, :hour)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       location:          location,
       plot_data_headers: plot_data_headers
     )
    }
  end

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
