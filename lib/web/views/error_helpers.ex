defmodule Web.ErrorHelpers do
  @moduledoc """
  Helper functions for translating and displaying inline form errors.

  Uses `Web.Gettext` and works with Phoenix.HTML form inputs to render
  error messages as `<span class="help-block">` elements.
  """

  use Phoenix.HTML

  @doc """
  Generates one or more inline tags for the given field's validation errors.

  ## Example

      <%= error_tag f, :email %>
  """
  def error_tag(form, field) do
    Keyword.get_values(form.errors, field)
    |> Enum.map(fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end)
  end

  @doc """
  Translates a validation error message using `Web.Gettext`.

  Automatically applies pluralization rules if `:count` is included in opts.
  """
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(Web.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Web.Gettext, "errors", msg, opts)
    end
  end
end
