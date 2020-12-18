defmodule HomeServer.SensorMeasurementAggregator do
  @moduledoc false

  use GenServer
  require Logger

  alias HomeServer.SensorMeasurementAggregator.{Batch, Storage}

  defmodule State do
    @moduledoc false
    @enforce_keys [:batch_size, :interval]
    defstruct batch_size: 1000, interval: 60_000
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(batch_size: batch_size, interval: interval) do
    state = %State{batch_size: batch_size, interval: interval}
    Process.send_after(self(), :process, state.interval)
    {:ok, state}
  end

  def handle_info(:process, state) do
    process(state.batch_size)
    Logger.info("processed SensorMeasurementAggregator")
    Process.send_after(self(), :process, state.interval)
    {:noreply, state}
  end

  @spec process(integer) :: nil
  def process(batch_size \\ 1000) do
    batch_size
    |> Storage.sensor_measurements_batch()
    |> Batch.process(batch_size)
  end
end
