defmodule HomeServerWeb.LocationLive.FormComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.UserLocations

  @impl true
  def update(%{location: location} = assigns, socket) do
    changeset = UserLocations.change_location(location, %{}, assigns.current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      socket.assigns.location
      |> UserLocations.change_location(location_params, socket.assigns.current_user)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    save_location(socket, socket.assigns.action, location_params)
  end

  defp save_location(socket, :edit, location_params) do
    case UserLocations.update_location(socket.assigns.location, location_params) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_location(socket, :new, location_params) do
    case UserLocations.create_location(location_params, socket.assigns.current_user) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Location created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
