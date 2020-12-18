defmodule HomeServerWeb.LocationLive.PlotComponent do
  use HomeServerWeb, :live_component

  alias HomeServer.LocationPlotQuery
  alias Contex.{LinePlot, Dataset, Plot}

  # initial render
  @impl true
  def update(
        %{plot_key: plot_key, timescale: timescale, html_class: html_class, timezone: timezone} =
          _assigns,
        socket
      ) do
    data =
      LocationPlotQuery.data(plot_key, timescale)
      |> Enum.map(fn [datetime | rest] ->
        [datetime |> DateTime.shift_zone!(timezone) |> DateTime.to_naive() | rest]
      end)

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

  @impl true
  def render(assigns) do
    ~L"""
      <%= @plot_svg %>
    """
  end

  def generate_plot_svg(plot_key, [], html_class) do
    placeholder_data = [[DateTime.now!("Etc/UTC"), 0.0, 0.0, 0.0, 0.0, 0.0]]
    generate_plot_svg(plot_key, placeholder_data, html_class)
  end

  def generate_plot_svg(plot_key, data, html_class) do
    ds = Dataset.new(data, ["X", "Max", "+1S", "Avg", "-1S", "Min"])

    options = [
      mapping: %{x_col: "X", y_cols: ["Max", "+1S", "Avg", "-1S", "Min"]},
      colour_palette: ["fbe5af", "fbc26f", "ff9838", "fbc26f", "fbe5af"],
      smoothed: false
    ]

    plot =
      Plot.new(ds, LinePlot, 600, 300, options)
      |> Plot.plot_options(%{legend_setting: :legend_right})
      |> Plot.titles(plot_key.quantity, plot_key.unit)

    Plot.to_svg(plot)
    |> apply_html_class(html_class)
  end

  def apply_html_class(plot_svg, html_class) do
    {:safe, [head, middle | tail]} = plot_svg

    middle =
      middle
      |> String.replace("class=\"chart", "class=\"chart #{html_class}", global: false)
      |> String.replace_suffix("", " preserveAspectRatio=\"xMidYMid meet\" x=\"0\" y=\"0\" ")

    {:safe, [head, middle | tail]}
  end

  def plot_component_id(plot_key) do
    [
      "PlotComponent",
      plot_key.location_id,
      plot_key.quantity,
      plot_key.unit
    ]
    |> Enum.join("_")
  end
end
