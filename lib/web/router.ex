defmodule Web.Router do
  @moduledoc false

  use Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Web.Plugs.FetchUser
  end

  pipeline :logged_in do
    plug Web.Plugs.EnsureUser
  end

  pipeline :admin do
    plug :put_layout, [{:html, {Web.Layouts, :admin}}]
    plug Web.Plugs.EnsureAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Web.Plugs.ValidateAPIKey
  end

  pipeline :ensure_profile_owner do
    plug Web.Plugs.EnsureProfileOwner
  end

  # Public / guest-accessible routes
  scope "/", Web do
    pipe_through :browser

    get "/", PageController, :index

    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    delete "/sign-out", SessionController, :delete

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    get "/register/reset", RegistrationResetController, :new
    post "/register/reset", RegistrationResetController, :create
    get "/register/reset/verify", RegistrationResetController, :edit
    post "/register/reset/verify", RegistrationResetController, :update

    get "/confirm/:code", ConfirmationController, :confirm, as: :confirmation
    get "/reset/:token", RegistrationResetController, :edit, as: :registration_reset

    get "/_health", PageController, :health
  end

  # Logged-in general routes
  scope "/", Web do
    pipe_through [:browser, :logged_in]

    get "/client", PageController, :client
    get "/client/*page", PageController, :client

    resources "/characters", CharacterController, only: [:create, :delete]
  end

  # Profile routes with :id access restriction
  scope "/users/:id", Web do
    pipe_through [:browser, :logged_in, :ensure_profile_owner]

    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "/profile", ProfileController, :update
  end

  # Admin panel
  scope "/admin", Web.Admin, as: :admin do
    pipe_through [:browser, :logged_in, :admin]

    get "/", DashboardController, :index

    post "/staged-changes/commit", StagedChangeController, :commit
    resources "/staged-changes", StagedChangeController, only: [:index, :delete]

    resources "/users", UserController, only: [:index, :show]

    resources "/rooms", RoomController, only: [:index, :show, :edit, :update]
    post "/rooms/:id/publish", RoomController, :publish, as: :room
    delete "/rooms/:id/changes", RoomController, :delete_changes, as: :room_changes

    resources "/zones", ZoneController, except: [:delete] do
      resources "/rooms", RoomController, only: [:new, :create]
    end

    post "/zones/:id/publish", ZoneController, :publish, as: :zone
    delete "/zones/:id/changes", ZoneController, :delete_changes, as: :zone_changes
  end

  # API routes
  scope "/api", Web.API, as: :api do
    pipe_through [:api]

    resources "/rooms", RoomController, only: [:index, :show] do
      resources "/staged-changes", StagedChangeController, only: [:index]
    end

    resources "/zones", ZoneController, only: [:index, :show] do
      resources "/rooms", RoomController, only: [:index]
      resources "/staged-changes", StagedChangeController, only: [:index]
    end

    resources "/staged-changes/:type", StagedChangeController, only: [:index]
  end

  if Mix.env() == :dev do
    forward "/dev/mailbox", Plug.Swoosh.MailboxPreview
  end
end
