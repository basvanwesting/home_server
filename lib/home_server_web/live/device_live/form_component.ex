defmodule HomeServerWeb.DeviceLive.FormComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.UserDevices
  alias HomeServer.UserLocations

  @impl true
  def update(%{device: device} = assigns, socket) do
    changeset = UserDevices.change_device(device, %{}, assigns.current_user)
    locations = UserLocations.list_locations(assigns.current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       locations: locations
     )}
  end

  @impl true
  def handle_event("validate", %{"device" => device_params}, socket) do
    changeset =
      socket.assigns.device
      |> UserDevices.change_device(device_params, socket.assigns.current_user)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    save_device(socket, socket.assigns.action, device_params)
  end

  defp save_device(socket, :edit, device_params) do
    case UserDevices.update_device(socket.assigns.device, device_params) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_device(socket, :new, device_params) do
    case UserDevices.create_device(device_params, socket.assigns.current_user) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
