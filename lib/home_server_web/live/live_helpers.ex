defmodule HomeServerWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `HomeServerWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, HomeServerWeb.SensorMeasurementLive.FormComponent,
        id: @sensor_measurement.id || :new,
        action: @live_action,
        sensor_measurement: @sensor_measurement,
        return_to: Routes.sensor_measurement_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, HomeServerWeb.ModalComponent, modal_opts)
  end
end
