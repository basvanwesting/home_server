# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HomeServer.Repo.insert!(%HomeServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

HomeServer.Repo.delete_all(HomeServer.Accounts.User)
HomeServer.Repo.delete_all(HomeServer.Locations.Location)
HomeServer.Repo.delete_all(HomeServer.SensorMeasurements.SensorMeasurement)

{:ok, admin} = HomeServer.Accounts.register_user(%{
  email: "admin@example.com",
  password: "admin123admin123"
})
{:ok, location_home} = HomeServer.Locations.create_location(%{
  user_id: admin.id,
  name: "Home"
})
{:ok, location_office} = HomeServer.Locations.create_location(%{
  user_id: admin.id,
  name: "Office"
})

current_time = DateTime.now!("Etc/UTC")
for i <- 0..100 do
  {:ok, _sensor_measurement} = HomeServer.SensorMeasurements.create_sensor_measurement(%{
    location_id: location_office.id,
    measured_at: DateTime.add(current_time, -30 * i, :second),
    quantity:    "Temperature",
    value:       :rand.normal() * 10 + 20,
    unit:        "Celsius",
    host:        "localhost",
    sensor:      "A0",
  })
  {:ok, _sensor_measurement} = HomeServer.SensorMeasurements.create_sensor_measurement(%{
    location_id: location_office.id,
    measured_at: DateTime.add(current_time, -30 * i, :second),
    quantity:    "CO2",
    value:       :rand.normal() * 100 + 500,
    unit:        "ppm",
    host:        "localhost",
    sensor:      "A1",
  })
end
