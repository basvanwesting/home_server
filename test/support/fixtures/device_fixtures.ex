defmodule HomeServer.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeServer.Devices` context.
  """

  alias HomeServer.Devices
  import HomeServer.AccountsFixtures

  def device_fixture(attrs \\ %{})

  def device_fixture(%{user_id: user_id} = attrs) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        user_id: user_id,
        identifier: "some identifier",
      })
      |> Devices.create_device()

    device
  end

  def device_fixture(attrs) do
    %{id: user_id} = _user = user_fixture()
    device_fixture(Map.put(attrs, :user_id, user_id))
  end

end
