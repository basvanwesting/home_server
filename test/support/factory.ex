defmodule HomeServer.Factory do
  use ExMachina.Ecto, repo: HomeServer.Repo

  defdelegate forget_all(struct), to: HomeServer.Repo
  defdelegate forget(struct, associations), to: HomeServer.Repo

  def device_factory do
    %HomeServer.Devices.Device{
      identifier: "some identifier"
    }
  end

  def location_factory do
    %HomeServer.Locations.Location{
      name: "some name",
      user: build(:user),
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
