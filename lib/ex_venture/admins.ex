defmodule ExVenture.Admins do
  @moduledoc """
  The Admins context.
  """

  import Ecto.Query, warn: false
  alias ExVenture.Repo
  alias ExVenture.Admins.Admin

  def get_admin!(id), do: Repo.get!(Admin, id)

  def get_admin_by_email(email) when is_binary(email) do
    Repo.get_by(Admin, email: email)
  end

  def register_admin(attrs \\ %{}) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_admin_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    admin = get_admin_by_email(email)
    if admin && Argon2.verify_pass(password, admin.password_hash) do
      {:ok, admin}
    else
      {:error, :invalid_credentials}
    end
  end

  def change_admin_registration(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end

  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end
end
