defmodule Web.ProfileView do
  use Phoenix.Component
use Phoenix.HTML
import Web.Gettext
import Web.CoreComponents
alias Web.Router.Helpers, as: Routes

  alias ExVenture.Users.Avatar
  alias Web.FormView

  def avatar?(user), do: user.avatar_key != nil

  def avatar_img(user) do
    link(to: Stein.Storage.url(Avatar.avatar_path(user, "original"))) do
      img_tag(Stein.Storage.url(Avatar.avatar_path(user, "thumbnail")))
    end
  end
end
