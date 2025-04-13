defmodule Web.Admin.UserController do
  use Web, :controller

  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  alias ExVenture.Users

  plug(Web.Plugs.ActiveTab, tab: :users)
  plug(Web.Plugs.FetchPage when action in [:index])

  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: users, pagination: pagination} = Users.all(page: page, per: per)

    conn
    |> assign(:users, users)
    |> assign(:pagination, pagination)
    |> assign(:path, ~p"/admin/users")
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    {:ok, user} = Users.get(id)

    conn
    |> assign(:user, user)
    |> render("show.html")
  end
end
