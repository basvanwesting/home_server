defmodule HomeServer.UserDevices do
  @moduledoc """
  The Devices context as seen from the to the mandatory belongs_to user
  """

  import Ecto.Query, warn: false
  alias HomeServer.Repo

  alias HomeServer.Devices.Device
  alias HomeServer.Accounts.User

  @spec list_devices(User.t()) :: [Device.t()]
  def list_devices(%User{} = user) do
    Repo.all(
      from e in Device,
      where: e.user_id == ^user.id
    )
  end

  @spec get_device!(non_neg_integer | binary, User.t()) :: Device.t()
  def get_device!(id, %User{} = user) do
    Repo.get_by!(Device, id: id, user_id: user.id)
  end

  def create_device(attrs \\ %{}, %User{} = user) do
    build_device(attrs, user)
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Ecto.Changeset.delete_change(:user_id)
    |> Repo.update()
  end

  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  def change_device(%Device{} = device, attrs \\ %{}, %User{} = user) do
    Device.changeset(device, attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
  end

  def build_device(attrs \\ %{}, %User{} = user) do
    Ecto.build_assoc(user, :devices, attrs)
  end

end
