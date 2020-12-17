defmodule HomeServerWeb.LocationLive.PlotComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.LocationPlotQuery
  alias Contex.{LinePlot, Dataset, Plot}

  #initial render
  @impl true
  def update(%{plot_key: plot_key, timescale: timescale, html_class: html_class} = _assigns, socket) do
    data = LocationPlotQuery.data(plot_key, timescale)
    plot_svg = generate_plot_svg(plot_key, data, html_class)

    {:ok,
     socket
     |> assign(
       plot_key: plot_key,
       timescale: timescale,
       html_class: html_class,
       data: data,
       plot_svg: plot_svg
     )}
  end

  # appended render
  def update(%{sensor_measurement: sensor_measurement} = _assigns, socket) do
    data = socket.assigns.data ++ [{sensor_measurement.measured_at, sensor_measurement.value}]
    plot_svg = generate_plot_svg(
      socket.assigns.plot_key,
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
      <%= @plot_svg %>
    """
  end

  def generate_plot_svg(plot_key, [], html_class) do
    placeholder_data = [{DateTime.now!("Etc/UTC"), 0.0}]
    generate_plot_svg(plot_key, placeholder_data, html_class)
  end
  def generate_plot_svg(plot_key, data, html_class) do
    ds = Dataset.new(data)
    line_plot = LinePlot.new(ds)

    plot = Plot.new(600, 300, line_plot)
     #|> Plot.plot_options(%{legend_setting: :legend_right})
     |> Plot.titles(plot_key.quantity, plot_key.unit)

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

  def plot_component_id(plot_key) do
    [
      "PlotComponent",
      plot_key.location_id,
      plot_key.quantity,
      plot_key.unit,
    ] |> Enum.join("_")
  end
end
