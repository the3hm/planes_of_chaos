defmodule Web.ProfileView do
  @moduledoc """
  View logic for user profile pages, including avatar rendering helpers.
  """

  use Phoenix.Component

  import Phoenix.Component
  import Web.Gettext

  alias ExVenture.Users.Avatar

  @doc "Returns true if the user has an avatar"
  def avatar?(user), do: user.avatar_key != nil

  @doc """
  Renders an avatar image wrapped in a link to the full-size image.

  ## Example

      <.avatar_img user={@user} />
  """
  attr :user, :map, required: true

  def avatar_img(assigns) do
    ~H"""
    <a href={Stein.Storage.url(Avatar.avatar_path(@user, "original"))} target="_blank">
      <img src={Stein.Storage.url(Avatar.avatar_path(@user, "thumbnail"))} alt="avatar" class="rounded-full w-24 h-24 object-cover" />
    </a>
    """
  end
end
