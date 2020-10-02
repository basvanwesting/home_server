defmodule HomeServerWeb.SensorMeasurementLive.FormComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.SensorMeasurements

  @impl true
  def update(%{sensor_measurement: sensor_measurement} = assigns, socket) do
    changeset = SensorMeasurements.change_sensor_measurement(sensor_measurement)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"sensor_measurement" => sensor_measurement_params}, socket) do
    changeset =
      socket.assigns.sensor_measurement
      |> SensorMeasurements.change_sensor_measurement(sensor_measurement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sensor_measurement" => sensor_measurement_params}, socket) do
    save_sensor_measurement(socket, socket.assigns.action, sensor_measurement_params)
  end

  defp save_sensor_measurement(socket, :edit, sensor_measurement_params) do
    case SensorMeasurements.update_sensor_measurement(socket.assigns.sensor_measurement, sensor_measurement_params) do
      {:ok, _sensor_measurement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sensor measurement updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sensor_measurement(socket, :new, sensor_measurement_params) do
    case SensorMeasurements.create_sensor_measurement(sensor_measurement_params) do
      {:ok, _sensor_measurement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sensor measurement created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
