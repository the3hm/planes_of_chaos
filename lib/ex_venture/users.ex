defmodule ExVenture.Users.User do
  @moduledoc """
  User schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExVenture.Characters.PlayableCharacter

  @type t :: %__MODULE__{}

  schema "users" do
    field :token, Ecto.UUID
    field :role, :string
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :email_verification_token, Ecto.UUID
    field :email_verified_at, :utc_datetime

    field :password_reset_token, Ecto.UUID
    field :password_reset_expires_at, :utc_datetime

    field :avatar_key, Ecto.UUID
    field :avatar_extension, :string

    has_many :playable_characters, PlayableCharacter
    has_many :characters, through: [:playable_characters, :character]

    timestamps()
  end

  @doc """
  Changeset for creating a new user.
  """
  def create_changeset(struct, params) do
    struct
    |> cast(params, [:email, :username, :password, :password_confirmation])
    |> put_change(:token, UUID.uuid4())
    |> validate_confirmation(:password)
    |> Stein.Accounts.trim_field(:email)
    |> Stein.Accounts.trim_field(:username)
    |> Stein.Accounts.hash_password()
    |> Stein.Accounts.start_email_verification_changeset()
    |> validate_required([:email, :username, :password, :password_hash])
    |> unique_constraint(:username, name: :users_lower_username_index)
    |> unique_constraint(:email, name: :users_lower_email_index)
  end

  @doc """
  Changeset for updating email.
  """
  def update_changeset(struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email, name: :users_lower_email_index)
    |> maybe_restart_email_verification()
  end

  @doc """
  Changeset for updating password.
  """
  def password_changeset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> Stein.Accounts.hash_password()
  end

  @doc """
  Changeset for updating avatar fields.
  """
  def avatar_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:avatar_key, key)
    |> put_change(:avatar_extension, extension)
  end

  defp maybe_restart_email_verification(changeset) do
    if get_change(changeset, :email) do
      changeset
      |> Stein.Accounts.start_email_verification_changeset()
      |> put_change(:email_verified_at, nil)
    else
      changeset
    end
  end
end

defmodule ExVenture.Users do
  @moduledoc """
  Users context module.
  """

  import Ecto.Query

  alias ExVenture.Emails
  alias ExVenture.Mailer
  alias ExVenture.Repo
  alias ExVenture.Users.Avatar
  alias ExVenture.Users.User
  alias Stein.Accounts

  @doc "Returns an empty changeset for registration or session form."
  def new(), do: Ecto.Changeset.change(%User{}, %{})

  @doc "Returns a changeset for editing an existing user."
  def edit(user), do: Ecto.Changeset.change(user, %{})

  @doc "Checks if a user has admin privileges."
  def admin?(user), do: user.role == "admin"

  @doc "Lists all users with pagination support."
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})

    User
    |> order_by([u], desc: u.id)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  @doc "Fetch a user by ID."
  def get(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc "Fetch a user by token."
  def from_token(token) do
    case Repo.get_by(User, token: token) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc "Validates login with email and password."
  def validate_login(email, password) do
    Accounts.validate_login(Repo, User, email, password)
  end

  @doc "Creates a new user and sends a welcome email."
  def create(params) do
    changeset = User.create_changeset(%User{}, params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, changeset)
      |> Ecto.Multi.run(:avatar, fn _repo, %{user: user} ->
        Avatar.maybe_upload_avatar(user, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: user}} ->
        user
        |> Emails.welcome_email()
        |> Mailer.deliver()

        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc "Updates user profile and resends verification if email changed."
  def update(user, params) do
    changeset = User.update_changeset(user, params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:avatar, fn _repo, %{user: user} ->
        Avatar.maybe_upload_avatar(user, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: user}} ->
        maybe_verify_email_again(user, changeset)
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp maybe_verify_email_again(user, changeset) do
    if Ecto.Changeset.get_change(changeset, :email) do
      user
      |> case do
        %Swoosh.Email{} = email -> Mailer.deliver(email)
        _ -> {:error, :invalid_email}
      end
    else
      :ok
    end
  end

  @doc "Changes the user password after validating the current one."
  def change_password(user, current_password, params) do
    case validate_login(user.email, current_password) do
      {:error, :invalid} ->
        {:error, :invalid}

      {:ok, user} ->
        %User{}
        |> Ecto.Changeset.change(user)
        |> User.password_changeset(params)
        |> Repo.update()
    end
  end

  @doc "Verifies the user's email from token."
  def verify_email(token) do
    Accounts.verify_email(Repo, User, token)
  end

  @doc "Starts the password reset flow and sends the email."
  def start_password_reset(email) do
    Stein.Accounts.start_password_reset(Repo, User, email, fn user ->
      with %Swoosh.Email{} = email <- Emails.password_reset(user),
           {:ok, _response} <- Mailer.deliver(email) do
        {:ok, _response} -> {:ok, user}
        {:error, reason} -> {:error, reason}
      end
    end)
  end

  @doc """
Returns a blank changeset for login or session forms.

## Examples

    iex> ExVenture.Users.change_user_changeset()
    %Ecto.Changeset{...}
"""
def change_user_changeset do
  User.create_changeset(%User{}, %{})
end


  @doc "Performs the actual password reset from a valid token."
  def reset_password(token, params) do
    Stein.Accounts.reset_password(Repo, User, token, params)
  end
end
