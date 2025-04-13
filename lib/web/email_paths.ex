defmodule Web.EmailPaths do
  @moduledoc false

  @doc """
  Generates a full email confirmation URL.
  """
  def confirm_url(token) do
    Web.Endpoint.url() <> "/users/confirm/#{token}"
  end

  @doc """
  Generates a full password reset verification URL.
  """
  def reset_url(token) do
    Web.Endpoint.url() <> "/register/reset/verify/#{token}"
  end
end
