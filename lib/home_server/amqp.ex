defmodule HomeServer.AMQP do
  require Logger
  alias AMQP.{Connection, Channel, Queue, Exchange}

  def setup_sensor_measurements_queue() do
    with {:ok, queue_base} = Application.fetch_env(:amqp, :sensor_measurements_queue),
         {:ok, connection_options} = Application.fetch_env(:amqp, :connection_options),
         {:ok, conn} <- Connection.open(connection_options),
         {:ok, chan} <- Channel.open(conn),
         {:ok, _} <- Queue.declare(chan, "#{queue_base}_error", durable: true),
         # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
         {:ok, _} <- Queue.declare(chan, queue_base,
           durable: true,
           arguments: [
             {"x-dead-letter-exchange", :longstr, ""},
             {"x-dead-letter-routing-key", :longstr, "#{queue_base}_error"}
           ]
         ),
         :ok <- Exchange.fanout(chan, "#{queue_base}_exchange", durable: true),
         :ok <- Queue.bind(chan, queue_base, "#{queue_base}_exchange") do
      :ok
    else
      error ->
        Logger.error("Failed to setup sensor_measurements_queue: #{inspect error}")
        error
    end
  end

end
