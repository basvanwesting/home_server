defmodule HomeServer.SensorMeasurementsBroadway do
  use Broadway

  # alias Broadway.Message
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
    case message.data
         |> Jason.decode!()
         |> SensorMeasurements.create_sensor_measurement() do
      {:ok, _sensor_measurement} ->
        message

      {:error, _changeset} ->
        #_reason =
          #Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            #Enum.reduce(opts, msg, fn {key, value}, acc ->
              #String.replace(acc, "%{#{key}}", to_string(value))
            #end)
          #end)

        # Message.failed(message, reason)
        message
    end
  rescue
    _error ->
      # Message.failed(message, error)
      message
  end

  @impl true
  def handle_failed([message], _) do
    [message]
  end
end
