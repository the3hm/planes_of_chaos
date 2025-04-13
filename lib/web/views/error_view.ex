defmodule Web.ErrorView do
  @moduledoc """
  Renders errors as JSON for API endpoints or HTML fallbacks when templates are used.
  """

  alias Phoenix.Controller

  @doc """
  Renders a JSON error for 404 Not Found.
  """
  def render("404.json", _assigns) do
    %{
      errors: %{
        resource: ["Not Found"]
      }
    }
  end

  @doc """
  Default fallback: converts the template name to a status message.

  For example: "500.html" → "Internal Server Error"
  """
  def template_not_found(template, _assigns) do
    Controller.status_message_from_template(template)
  end
end
