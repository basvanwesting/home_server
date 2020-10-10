defmodule HomeServer.SensorMeasurementsBroadway do
  use Broadway

  #alias Broadway.Message
  alias HomeServer.SensorMeasurements

  def start_link(_opts) do
    producer_module = Application.fetch_env!(:broadway, :producer_module)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: producer_module,
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
    #{:ok, _sensor_measurement} =
      message.data
      |> Jason.decode!
      |> SensorMeasurements.create_sensor_measurement

    message
  end

end
