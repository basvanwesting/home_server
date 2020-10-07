defmodule HomeServer.SensorMeasurementsBroadway do
  use Broadway

  #alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayRabbitMQ.Producer,
          queue: Application.fetch_env!(:amqp, :sensor_measurements_queue),
          connection: Application.fetch_env!(:amqp, :connection_options),
          qos: [
            prefetch_count: 50,
          ]
        },
        concurrency: 2
      ],
      processors: [
        default: [
          concurrency: 50
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    IO.inspect(message.data, label: "Got message")
    message
  end

end
