defmodule HomeServer.Factory do
  use ExMachina.Ecto, repo: HomeServer.Repo

  defdelegate forget_all(struct), to: HomeServer.Repo
  defdelegate forget(struct, associations), to: HomeServer.Repo

  def location_factory do
    %HomeServer.Locations.Location{
      name: "some name",
      user: build(:user),
    }
  end

  def device_factory do
    %HomeServer.Devices.Device{
      identifier: "some identifier"
    }
  end

  def sensor_measurement_factory do
    %HomeServer.SensorMeasurements.SensorMeasurement{
      measured_at: "2020-01-01T12:00:00Z",
      quantity: "Temperature",
      value: "22.0",
      unit: "Celsius",
      host: "localhost",
      sensor: "A0",
      aggregated: false,
    }
  end

  def sensor_measurement_aggregate_factory do
    %HomeServer.SensorMeasurementAggregates.SensorMeasurementAggregate{
      resolution: "hour",
      quantity: "Temperature",
      unit: "Celsius",
      measured_at: "2020-01-01T12:00:00Z",
      average: "22.0",
      min: "20.0",
      max: "25.0",
      stddev: "1.0",
      count: 60
    }
  end

  def user_factory do
    %HomeServer.Accounts.User{
      email: unique_user_email(),
      hashed_password: valid_user_password() |> Bcrypt.hash_pwd_salt(),
    }
  end

  def unique_user_email, do: sequence(:email, &"user-#{&1}@example.com")
  def valid_user_password, do: "hello world!"

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end

end
