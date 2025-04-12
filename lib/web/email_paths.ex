defmodule Web.EmailPaths do
  @moduledoc false

  import Web.VerifiedRoutes

  def confirm_url(token) do
    Web.Endpoint.url() <> ~p"/users/confirm/#{token}"
  end

  def reset_url(token) do
    Web.Endpoint.url() <> ~p"/register/reset/verify/#{token}"
  end
end
