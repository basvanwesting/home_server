defmodule HomeServer.SensorMeasurementAggregates do
  @moduledoc """
  The SensorMeasurementAggregates context.
  """

  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate
  alias HomeServer.Locations

  @doc """
  Returns the list of sensor_measurement_aggregates.

  ## Examples

      iex> list_sensor_measurement_aggregates()
      [%SensorMeasurementAggregate{}, ...]

  """
  def list_sensor_measurement_aggregates(opts \\ [])
  def list_sensor_measurement_aggregates(limit: limit) when limit > 0 do
    SensorMeasurementAggregate
    |> limit(^limit)
    |> order_by(desc: :measured_at)
    |> Repo.all
  end
  def list_sensor_measurement_aggregates([]) do
    Repo.all(SensorMeasurementAggregate)
  end

  @doc """
  Gets a single sensor_measurement_aggregate.

  Raises `Ecto.NoResultsError` if the Sensor measurement_aggregate does not exist.

  ## Examples

      iex> get_sensor_measurement_aggregate!(123)
      %SensorMeasurementAggregate{}

      iex> get_sensor_measurement_aggregate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor_measurement_aggregate!(id), do: Repo.get!(SensorMeasurementAggregate, id)

  @doc """
  Creates a sensor_measurement_aggregate.

  ## Examples

      iex> create_sensor_measurement_aggregate(%{field: value})
      {:ok, %SensorMeasurementAggregate{}}

      iex> create_sensor_measurement_aggregate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor_measurement_aggregate(attrs \\ %{}) do
    %SensorMeasurementAggregate{}
    |> SensorMeasurementAggregate.changeset(attrs)
    |> Repo.insert(
      #conflict_target: :sensor_measurement_aggregates_location_id_resolution_quantity_u,
      #on_conflict: {:replace, [:average, :min, :max, :stddev, :count]}
    )
    |> broadcast(:sensor_measurement_aggregate_created)
  end

  @doc """
  Updates a sensor_measurement_aggregate.

  ## Examples

      iex> update_sensor_measurement_aggregate(sensor_measurement_aggregate, %{field: new_value})
      {:ok, %SensorMeasurementAggregate{}}

      iex> update_sensor_measurement_aggregate(sensor_measurement_aggregate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor_measurement_aggregate(%SensorMeasurementAggregate{} = sensor_measurement_aggregate, attrs) do
    sensor_measurement_aggregate
    |> SensorMeasurementAggregate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sensor_measurement_aggregate.

  ## Examples

      iex> delete_sensor_measurement_aggregate(sensor_measurement_aggregate)
      {:ok, %SensorMeasurementAggregate{}}

      iex> delete_sensor_measurement_aggregate(sensor_measurement_aggregate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor_measurement_aggregate(%SensorMeasurementAggregate{} = sensor_measurement_aggregate) do
    Repo.delete(sensor_measurement_aggregate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor_measurement_aggregate changes.

  ## Examples

      iex> change_sensor_measurement_aggregate(sensor_measurement_aggregate)
      %Ecto.Changeset{data: %SensorMeasurementAggregate{}}

  """
  def change_sensor_measurement_aggregate(%SensorMeasurementAggregate{} = sensor_measurement_aggregate, attrs \\ %{}) do
    SensorMeasurementAggregate.changeset(sensor_measurement_aggregate, attrs)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(HomeServer.PubSub, sensor_measurement_aggregates_topic())
  end

  def broadcast({:ok, sensor_measurement_aggregate}, name) do
    Phoenix.PubSub.broadcast(
      HomeServer.PubSub,
      sensor_measurement_aggregates_topic(),
      {name, sensor_measurement_aggregate}
    )
    Phoenix.PubSub.broadcast(
      HomeServer.PubSub,
      Locations.location_topic(sensor_measurement_aggregate),
      {name, sensor_measurement_aggregate}
    )
    {:ok, sensor_measurement_aggregate}
  end
  def broadcast({:error, _changeset} = error, _name), do: error

  def sensor_measurement_aggregates_topic(), do: "sensor_measurement_aggregates"
end
