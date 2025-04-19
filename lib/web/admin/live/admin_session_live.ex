defmodule Web.Admin.AdminSessionLive do
  use Web, :live_view

  alias ExVenture.Admins

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin Login")
      |> assign(:email, "")
      |> assign(:password, "")

    {:ok, socket}
  end

  def handle_event("validate", %{"admin" => params}, socket) do
    {:noreply, assign(socket, email: params["email"], password: params["password"])}
  end

  def handle_event("login", %{"admin" => %{"email" => email, "password" => password}}, socket) do
    case Admins.authenticate_admin_by_email_and_password(email, password) do
      {:ok, admin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> redirect(to: ~p"/admin?admin_id=#{admin.id}")}

      {:error, :invalid_credentials} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password")
         |> assign(email: email)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div>
          <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Admin Login
          </h2>
        </div>
        <.form
          for={%{}}
          as={:admin}
          id="login-form"
          phx-submit="login"
          phx-change="validate"
          class="mt-8 space-y-6"
        >
          <div class="rounded-md shadow-sm -space-y-px">
            <div>
              <label for="email" class="sr-only">Email address</label>
              <input
                type="email"
                name="admin[email]"
                value={@email}
                required
                class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
              />
            </div>
            <div>
              <label for="password" class="sr-only">Password</label>
              <input
                type="password"
                name="admin[password]"
                value={@password}
                required
                class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
                placeholder="Password"
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              phx-disable-with="Signing in..."
            >
              Sign in
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
