defmodule Web.EmailPaths do
  @moduledoc false

  import Web.VerifiedRoutes

  @doc """
  Generates a full email confirmation URL without using ~p sigil.
  """
  def confirm_url(token) do
    path = Web.VerifiedRoutes.path(Web.Endpoint, Web.Router, "/users/confirm/#{token}")
    Web.Endpoint.url() <> path
  end

  @doc """
  Generates a full password reset verification URL without using ~p sigil.
  """
  def reset_url(token) do
    path = Web.VerifiedRoutes.path(Web.Endpoint, Web.Router, "/register/reset/verify/#{token}")
    Web.Endpoint.url() <> path
  end
end
