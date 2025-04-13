defmodule ExVenture.Users.Avatar do
  @moduledoc """
  Handles uploading avatars to remote storage for users.
  """

  require Logger

  alias ExVenture.Images
  alias ExVenture.Users.User
  alias ExVenture.Repo

  alias Stein.Storage
  alias Stein.Storage.FileUpload

  @doc """
  If the `avatar` param is present, uploads the avatar image.
  """
  @spec maybe_upload_avatar(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def maybe_upload_avatar(user, params) do
    params = Map.new(params, fn {k, v} -> {to_string(k), v} end)
    maybe_upload_avatar_image(user, params)
  end

  @doc """
  Returns the avatar path based on the user and image size.
  """
  @spec avatar_path(User.t(), String.t()) :: String.t()
  def avatar_path(user, size) do
    avatar_path(user.id, size, user.avatar_key, normalize_extension(user.avatar_extension))
  end

  defp avatar_path(user_id, size, key, ext) do
    "/" <> Path.join(["users", to_string(user_id), "avatar", "#{size}-#{key}#{ext}"])
  end

  defp normalize_extension(".png"), do: ".png"
  defp normalize_extension(_), do: ".png"

  @doc """
  Generates a new UUID key.
  """
  def generate_key, do: UUID.uuid4()

  @doc """
  Handles avatar image upload and DB update.
  """
  @spec maybe_upload_avatar_image(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def maybe_upload_avatar_image(user, %{"avatar" => file}) do
    user = Images.maybe_delete_old_images(user, :avatar_key, &avatar_path/2)

    file = Storage.prep_file(file)
    key = generate_key()
    path = avatar_path(user.id, "original", key, file.extension)

    changeset = User.avatar_changeset(user, key, file.extension)

    with :ok <- Images.upload(file, path),
         {:ok, user} <- Repo.update(changeset) do
      generate_avatar_versions(user, file)
    else
      _ ->
        user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "could not upload, please try again")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  def maybe_upload_avatar_image(user, _), do: {:ok, user}

  @doc """
  Generates a PNG thumbnail of the avatar.
  """
  @spec generate_avatar_versions(User.t(), FileUpload.t()) :: {:ok, User.t()}
  def generate_avatar_versions(user, %FileUpload{} = file) do
    path = avatar_path(user, "thumbnail")

    case Images.convert(file, extname: ".png", thumbnail: "200x200") do
      {:ok, temp_path} ->
        thumbnail_file = %FileUpload{
          path: temp_path,
          extension: ".png",
          filename: Path.basename(temp_path)
        }

        Images.upload(thumbnail_file, path)
        {:ok, user}

      {:error, :convert} ->
        {:ok, user}
    end
  end

  @doc """
  Regenerates the user's avatar thumbnail from the original.
  """
  @spec regenerate_avatar(User.t()) :: {:ok, User.t()} | {:error, term()}
  def regenerate_avatar(user) do
    case Storage.download(avatar_path(user, "original")) do
      {:ok, temp_path} ->
        file = %FileUpload{
          path: temp_path,
          extension: ".png",
          filename: Path.basename(temp_path)
        }

        generate_avatar_versions(user, file)

      error ->
        Logger.error("Failed to download original avatar: #{inspect(error)}")
        {:error, {:download_failed, error}}
    end
  end
end
