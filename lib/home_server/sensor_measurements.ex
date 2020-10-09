defmodule HomeServer.SensorMeasurements do
  @moduledoc """
  The SensorMeasurements context.
  """

  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.SensorMeasurements.SensorMeasurement

  @doc """
  Returns the list of sensor_measurements.

  ## Examples

      iex> list_sensor_measurements()
      [%SensorMeasurement{}, ...]

  """
  def list_sensor_measurements(opts \\ [])
  def list_sensor_measurements(limit: limit) when limit > 0 do
    SensorMeasurement
    |> limit(^limit)
    |> Repo.all
  end
  def list_sensor_measurements([]) do
    Repo.all(SensorMeasurement)
  end

  @doc """
  Gets a single sensor_measurement.

  Raises `Ecto.NoResultsError` if the Sensor measurement does not exist.

  ## Examples

      iex> get_sensor_measurement!(123)
      %SensorMeasurement{}

      iex> get_sensor_measurement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor_measurement!(id), do: Repo.get!(SensorMeasurement, id)

  @doc """
  Creates a sensor_measurement.

  ## Examples

      iex> create_sensor_measurement(%{field: value})
      {:ok, %SensorMeasurement{}}

      iex> create_sensor_measurement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor_measurement(attrs \\ %{}) do
    %SensorMeasurement{}
    |> SensorMeasurement.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:sensor_measurement_created)
  end

  @doc """
  Updates a sensor_measurement.

  ## Examples

      iex> update_sensor_measurement(sensor_measurement, %{field: new_value})
      {:ok, %SensorMeasurement{}}

      iex> update_sensor_measurement(sensor_measurement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor_measurement(%SensorMeasurement{} = sensor_measurement, attrs) do
    sensor_measurement
    |> SensorMeasurement.changeset(attrs)
    |> Repo.update()
    #|> broadcast(:sensor_measurement_updated)
  end

  @doc """
  Deletes a sensor_measurement.

  ## Examples

      iex> delete_sensor_measurement(sensor_measurement)
      {:ok, %SensorMeasurement{}}

      iex> delete_sensor_measurement(sensor_measurement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor_measurement(%SensorMeasurement{} = sensor_measurement) do
    Repo.delete(sensor_measurement)
    |> broadcast(:sensor_measurement_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor_measurement changes.

  ## Examples

      iex> change_sensor_measurement(sensor_measurement)
      %Ecto.Changeset{data: %SensorMeasurement{}}

  """
  def change_sensor_measurement(%SensorMeasurement{} = sensor_measurement, attrs \\ %{}) do
    SensorMeasurement.changeset(sensor_measurement, attrs)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(HomeServer.PubSub, "sensor_measurements")
  end

  def broadcast({:ok, sensor_measurement}, name) do
    Phoenix.PubSub.broadcast(
      HomeServer.PubSub,
      "sensor_measurements",
      {name, sensor_measurement}
    )
    {:ok, sensor_measurement}
  end
  def broadcast({:error, _changeset} = error, _name), do: error

end
