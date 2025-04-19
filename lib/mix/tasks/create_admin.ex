defmodule Mix.Tasks.ExVenture.CreateAdmin do
  @moduledoc """
  Creates a new admin user.

  ## Examples

      $ mix ex_venture.create_admin admin@example.com password123
  """

  use Mix.Task

  alias ExVenture.Admins

  @shortdoc "Creates a new admin user"

  @impl Mix.Task
  def run([email, password]) do
    Mix.Task.run("app.start")

    case Admins.register_admin(%{
      email: email,
      password: password,
      password_confirmation: password
    }) do
      {:ok, admin} ->
        Mix.shell().info("""
        Admin created successfully!
        Email: #{admin.email}
        """)

      {:error, changeset} ->
        Mix.shell().error("Failed to create admin:")

        changeset.errors
        |> Enum.map(fn {field, {message, _opts}} ->
          Mix.shell().error("  #{field}: #{message}")
        end)

        System.halt(1)
    end
  end

  def run(_args) do
    Mix.shell().error("""
    Usage: mix ex_venture.create_admin EMAIL PASSWORD

    Examples:
        $ mix ex_venture.create_admin admin@example.com password123
    """)

    System.halt(1)
  end
end
