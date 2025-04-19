defmodule Web.LiveViewBase do
  @moduledoc """
  Provides the base setup for LiveView modules.
  """
  use Phoenix.Component

  # Imports needed for the layout function component below
  use Gettext, backend: Web.Gettext
  alias Web.Router.Helpers, as: Routes
  use Phoenix.VerifiedRoutes,
    endpoint: Web.Endpoint,
    router: Web.Router,
    statics: Web.static_paths()

  # Define the app layout as a function component
  def app(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <.live_title suffix={" · #{gettext("ExVenture")}"}>
          <%= assigns[:page_title] || gettext("ExVenture") %>
        </.live_title>

        <link rel="stylesheet" href={~p"/assets/app.css"} phx-track-static />
        <meta property="og:site_name" content={gettext("ExVenture")} />

        <%= if assigns[:open_graph_title] do %>
          <meta property="og:title" content={@open_graph_title} />
        <% end %>

        <%= if assigns[:open_graph_description] do %>
          <meta property="og:description" content={@open_graph_description} />
        <% end %>

        <%= if assigns[:open_graph_url] do %>
          <meta property="og:url" content={@open_graph_url} />
        <% end %>

        <meta name="twitter:card" content="summary" />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>

      <body class="bg-gray-100 admin">
        <div class="md:w-full md:z-20 flex flex-row flex-wrap items-center bg-white px-5 py-2 border-b border-purple-400">
          <div class="w-56 flex flex-row items-center">
            <.link navigate={~p"/admin"} class="flex-1 font-bold">
              <img src={~p"/images/exventure.png"} class="h-8 inline-block" />
              <span class="ml-1 inline-block text-purple-900">ExVenture</span>
            </.link>
          </div>

          <div class="flex-grow flex justify-end items-center">
            <%= if assigns[:current_user] do %>
              <span class="inline-block mx-2"><%= @current_user.email %></span>
              <.link navigate={~p"/sign-out"} method="delete" class="btn-secondary text-sm">
                Sign Out
              </.link>
            <% else %>
              <.link navigate={~p"/sign-in"} class="btn-secondary text-sm">
                Sign In
              </.link>
            <% end %>
          </div>
        </div>

        <main role="main" class="px-4 py-6">
          <%= @inner_content %>
        </main>
      </body>
    </html>
    """
  end

  defmacro __using__(_opts) do
    quote do
      # Core LiveView setup, using the layout defined in this module
      use Phoenix.LiveView,
        layout: {Web.LiveViewBase, :app}

      # Gettext
      import Web.Gettext
      import Web.CoreComponents
      import Phoenix.HTML.Form

      # Verified Routes
      use Phoenix.VerifiedRoutes,
        endpoint: Web.Endpoint,
        router: Web.Router,
        statics: Web.static_paths()

      # Route Helpers Alias
      alias Web.Router.Helpers, as: Routes
    end
  end
end
