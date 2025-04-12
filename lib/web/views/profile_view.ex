defmodule Web.ProfileView do
  @moduledoc """
  View logic for user profile pages, including avatar rendering.
  """

  use Phoenix.View, root: "lib/web/templates", namespace: Web

  use Phoenix.HTML
  import Web.Gettext
  import Web.CoreComponents
  alias Web.Router.Helpers, as: Routes

  alias ExVenture.Users.Avatar
  alias Web.FormView

  @doc "Returns true if the user has an avatar"
  def avatar?(user), do: user.avatar_key != nil

  @doc "Renders an avatar image wrapped in a link to the full-size image"
  def avatar_img(user) do
    link(to: Stein.Storage.url(Avatar.avatar_path(user, "original"))) do
      img_tag(Stein.Storage.url(Avatar.avatar_path(user, "thumbnail")))
    end
  end
end
