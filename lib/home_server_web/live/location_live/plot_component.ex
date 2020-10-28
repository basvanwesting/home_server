defmodule HomeServerWeb.LocationLive.PlotComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.LocationPlotQuery
  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

  #initial render
  @impl true
  def update(%{sensor_measurement_key: sensor_measurement_key, timescale: timescale, html_class: html_class} = _assigns, socket) do
    data = LocationPlotQuery.raw_data(sensor_measurement_key, timescale)
    plot_svg = generate_plot_svg(sensor_measurement_key, data, html_class)

    {:ok,
     socket
     |> assign(
       sensor_measurement_key: sensor_measurement_key,
       timescale: timescale,
       html_class: html_class,
       data: data,
       plot_svg: plot_svg
     )}
  end

  # appended render
  def update(%{sensor_measurement: sensor_measurement} = _assigns, socket) do
    data = socket.assigns.data ++ [{sensor_measurement.measured_at, Decimal.to_float(sensor_measurement.value)}]
    plot_svg = generate_plot_svg(
      socket.assigns.sensor_measurement_key,
      data,
      socket.assigns.html_class
    )

    {:ok,
     socket
     |> assign(
       data: data,
       plot_svg: plot_svg
     )}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= @plot_svg %>
    </div>
    """
  end

  def generate_plot_svg(sensor_measurement_key, [], html_class) do
    assigns = %{sensor_measurement_key: sensor_measurement_key, html_class: html_class}
    placeholder = ~L"""
      <svg xmlns="http://www.w3.org/2000/svg" width="600" height="300" viewBox="0 0 600 300" class="chart <%= @html_class %>">
        <rect fill="#ddd" width="500" height="200" x="50" y="50"/>
        <text fill="rgba(0,0,0,0.5)" font-family="sans-serif" font-size="30" dy="10.5" font-weight="bold" x="50%" y="50%" text-anchor="middle">
          No data for <%= @sensor_measurement_key.quantity %> (<%= @sensor_measurement_key.unit %>)
        </text>
      </svg>
    """
    {:safe, placeholder}
  end
  def generate_plot_svg(sensor_measurement_key, data, html_class) do
    ds = Dataset.new(data)
    line_plot = LinePlot.new(ds)

    plot = Plot.new(600, 300, line_plot)
     #|> Plot.plot_options(%{legend_setting: :legend_right})
     |> Plot.titles(sensor_measurement_key.quantity, sensor_measurement_key.unit)

    Plot.to_svg(plot)
    |> apply_html_class(html_class)
  end

  def apply_html_class(plot_svg, html_class) do
    {:safe, [head, middle | tail]} = plot_svg
    middle = middle
      |> String.replace("class=\"chart", "class=\"chart #{html_class}", global: false)
      |> String.replace_suffix("", " preserveAspectRatio=\"xMidYMid meet\" x=\"0\" y=\"0\" ")
    {:safe, [head, middle | tail]}
  end

  def plot_component_id(sensor_measurement_key) do
    [
      "PlotComponent",
      sensor_measurement_key.location_id,
      sensor_measurement_key.quantity,
      sensor_measurement_key.unit,
    ] |> Enum.join("_")
  end
end
