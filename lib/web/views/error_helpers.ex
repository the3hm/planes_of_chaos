defmodule Web.ErrorHelpers do
  @moduledoc """
  Helper components for rendering and translating inline form errors.

  Defines `<.error_tag />` as a reusable HEEx component, and a `translate_error/1`
  function that uses `Web.Gettext` for error message translation.
  """

  use Phoenix.Component

  @doc """
  Inline error tag component. Renders all errors for a given form field.

  ## Examples

      <.error_tag form={f} field={:email} />
  """
  attr :form, :any, required: true
  attr :field, :atom, required: true

  def error_tag(assigns) do
    ~H"""
    <%= for error <- Keyword.get_values(@form.errors, @field) do %>
      <span class="help-block"><%= translate_error(error) %></span>
    <% end %>
    """
  end

  @doc """
  Translates an Ecto validation error message using Gettext.

  Automatically uses pluralization if `:count` is present in opts.
  """
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(Web.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Web.Gettext, "errors", msg, opts)
    end
  end
end
