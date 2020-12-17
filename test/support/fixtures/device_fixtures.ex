defmodule HomeServer.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeServer.Devices` context.
  """

  alias HomeServer.Devices

  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        identifier: "some identifier"
      })
      |> Devices.create_device()

    device
  end
end
