defmodule Web.Router do
  @moduledoc false

  use Web, :router

  # -------------------------------------------------------------
  # Pipelines
  # -------------------------------------------------------------
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_live_flash
    plug Web.Plugs.FetchUser
    plug Web.Plugs.PutCsrfTokenIntoSession
  end

  pipeline :logged_in do
    plug Web.Plugs.EnsureUser
  end

  pipeline :admin do
    plug :put_layout, [{:html, {Web.Layouts, :admin}}]
    plug Web.Plugs.EnsureAdmin
    plug :fetch_session
    plug :fetch_live_flash
  end

  pipeline :admin_layout do
    plug :put_layout, {Web.Layouts, :admin}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Web.Plugs.ValidateAPIKey
  end

  pipeline :ensure_profile_owner do
    plug Web.Plugs.EnsureProfileOwner
  end

  # -------------------------------------------------------------
  # Public / Guest Routes
  # -------------------------------------------------------------
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

  # -------------------------------------------------------------
  # Logged-In Routes
  # -------------------------------------------------------------
  scope "/", Web do
    pipe_through [:browser, :logged_in]

    get "/client", PageController, :client
    get "/client/*page", PageController, :client

    resources "/characters", CharacterController, only: [:create, :delete]
  end

  # -------------------------------------------------------------
  # User Profile Routes
  # -------------------------------------------------------------
  scope "/users/:id", Web do
    pipe_through [:browser, :logged_in, :ensure_profile_owner]

    get "/profile", ProfileController, :show
    get "/profile/edit", ProfileController, :edit
    put "/profile", ProfileController, :update
  end

  # -------------------------------------------------------------
  # Admin Panel + LiveView Dashboard
  # -------------------------------------------------------------
  scope "/admin", Web.Admin, as: :admin do
    pipe_through [:browser]

    live "/login", AdminSessionLive, :index
    delete "/logout", AdminSessionController, :delete
  end

  scope "/admin", Web.Admin, as: :admin do
    pipe_through [:browser, :logged_in, :admin]

    # Dashboard
    live "/", DashboardLive

    # Users Management
    live "/users", UsersLive
    live "/users/:id", UserDetailLive
    get "/users/export", UserExportController, :export

    # Characters Management
    live "/characters", CharactersLive

    # Zones & Rooms
    live "/zones", ZonesLive
    live "/zones/new", ZonesLive, :new
    live "/zones/:id", ZonesLive, :show

    # Nested Rooms under Zones
    live "/zones/:zone_id/rooms", RoomsLive
    live "/zones/:zone_id/rooms/new", RoomsLive, :new
    live "/zones/:zone_id/rooms/:id", RoomsLive, :show

    # Staged Changes
    post "/staged-changes/commit", StagedChangeController, :commit
    resources "/staged-changes", StagedChangeController, only: [:index, :delete]
  end

  # -------------------------------------------------------------
  # API Routes
  # -------------------------------------------------------------
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

  # -------------------------------------------------------------
  # Dev Tools
  # -------------------------------------------------------------
  if Mix.env() == :dev do
    forward "/dev/mailbox", Plug.Swoosh.MailboxPreview
  end
end
