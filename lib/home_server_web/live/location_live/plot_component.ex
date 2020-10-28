defmodule HomeServerWeb.LocationLive.PlotComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.LocationPlotQuery
  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

  @impl true
  def update(%{sensor_measurement_key: sensor_measurement_key, timescale: timescale, html_class: html_class} = assigns, socket) do
    data = LocationPlotQuery.raw_data(sensor_measurement_key, timescale)
    ds = Dataset.new(data)
    line_plot = LinePlot.new(ds)

    plot = Plot.new(600, 300, line_plot)
     #|> Plot.plot_options(%{legend_setting: :legend_right})
     |> Plot.titles(sensor_measurement_key.quantity, sensor_measurement_key.unit)

    plot_svg = Plot.to_svg(plot)
               |> apply_html_class(html_class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:plot_svg, plot_svg)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= @plot_svg %>
    </div>
    """
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
