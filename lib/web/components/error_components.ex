defmodule Web.ErrorComponents do
  @moduledoc """
  Component-based error helpers for form fields.
  """

  use Phoenix.Component

  attr :form, :map, required: true
  attr :field, :atom, required: true

  @doc "Render inline validation errors for a form field"
  def error_tag(assigns) do
    ~H"""
    <%= for {msg, _} <- Keyword.get_values(@form.errors, @field) do %>
      <span class="help-block"><%= msg %></span>
    <% end %>
    """
  end
end
