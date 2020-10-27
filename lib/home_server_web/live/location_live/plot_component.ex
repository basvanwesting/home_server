defmodule HomeServerWeb.LocationLive.PlotComponent do
  use HomeServerWeb, :live_component

  #alias HomeServer.UserLocations
  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

  @impl true
  def update(%{location: _location, html_class: html_class} = assigns, socket) do
    data = [{1, 1}, {2, 2}, {3, 2}, {4, 3}]
    ds = Dataset.new(data, ["x", "y"])
    line_plot = LinePlot.new(ds)

    plot = Plot.new(600, 300, line_plot)
     |> Plot.plot_options(%{legend_setting: :legend_right})
     |> Plot.titles("My first plot", "With a fancy subtitle")

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
end
