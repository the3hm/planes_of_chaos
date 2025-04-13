defmodule Web.ConfirmationController do
  @moduledoc """
  Handles email confirmation via verification code.
  """

  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  @doc """
  Confirms the user's email using a verification code.
  If no code is provided, falls back to error redirect.
  """
  def confirm(conn, %{"code" => code}) do
    case Users.verify_email(code) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Thanks for verifying your email!")
        |> put_session(:user_token, user.token)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an issue verifying your account")
        |> redirect(to: ~p"/")
    end
  end

  def confirm(conn, _params) do
    conn
    |> put_flash(:error, "There was an issue verifying your account")
    |> redirect(to: ~p"/")
  end
end
