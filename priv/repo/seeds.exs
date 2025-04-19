# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExVenture.Repo.insert!(%ExVenture.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ExVenture.Admins

# Create default admin user if it doesn't exist
case Admins.get_admin_by_email("admin@admin.com") do
  nil ->
    {:ok, _admin} =
      Admins.register_admin(%{
        email: "admin@admin.com",
        password: "admin1234",
        password_confirmation: "admin1234"
      })

    IO.puts("Created default admin user (admin@admin.com)")

  _admin ->
    IO.puts("Default admin user already exists")
end
