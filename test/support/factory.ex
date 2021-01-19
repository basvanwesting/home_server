defmodule HomeServer.Factory do
  use ExMachina.Ecto, repo: HomeServer.Repo

  alias HomeServer.Devices.Device

  def device_factory do
    %Device{
      identifier: "some identifier"
    }
  end

end
