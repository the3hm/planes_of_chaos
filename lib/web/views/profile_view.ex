defmodule Web.ProfileView do
  @moduledoc """
  View logic for user profile pages, including avatar rendering helpers.
  """

  import Phoenix.HTML.Link, only: [link: 2]
  import Phoenix.HTML.Tag, only: [img_tag: 2]
  import Web.Gettext

  alias ExVenture.Users.Avatar

  @doc "Returns true if the user has an avatar"
  def avatar?(user), do: user.avatar_key != nil

  @doc "Renders an avatar image wrapped in a link to the full-size image"
  def avatar_img(user) do
    link(to: Stein.Storage.url(Avatar.avatar_path(user, "original"))) do
      img_tag(Stein.Storage.url(Avatar.avatar_path(user, "thumbnail")), [])
    end
  end
end
