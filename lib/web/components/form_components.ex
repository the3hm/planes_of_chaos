defmodule Web.FormComponents do
  @moduledoc """
  FluxonUI-styled reusable form inputs as function components.

  Use in HEEx like:

      <.text_field form={@form} field={:email} label="Email" />
  """

  use Phoenix.Component

  import Web.ErrorComponents, only: [error_tag: 1]

  alias Phoenix.HTML.Form
  alias Phoenix.Naming

  # Shared attributes for all fields
  attr :form, :map, required: true
  attr :field, :atom, required: true
  attr :label, :string, default: nil
  attr :type, :string, default: "text"
  attr :opts, :global

  @doc "Fluxon-styled text field input"
  def text_field(assigns) do
    ~H"""
    <div class={form_group_class(@form, @field)}>
      <label for={Form.input_id(@form, @field)} class="label text-sm font-medium text-white">
        <%= @label || humanize(@field) %>
      </label>
      <input
        type={@type}
        name={Form.input_name(@form, @field)}
        id={Form.input_id(@form, @field)}
        value={Form.input_value(@form, @field)}
        class="input w-full bg-dracula-bg text-white border border-dracula-selection rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-dracula-purple"
        {@opts}
      />
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  attr :rows, :integer, default: 4

  @doc "Fluxon-styled textarea field"
  def textarea_field(assigns) do
    ~H"""
    <div class={form_group_class(@form, @field)}>
      <label for={Form.input_id(@form, @field)} class="label text-sm font-medium text-white">
        <%= @label || humanize(@field) %>
      </label>
      <textarea
        name={Form.input_name(@form, @field)}
        id={Form.input_id(@form, @field)}
        rows={@rows}
        class="input w-full bg-dracula-bg text-white border border-dracula-selection rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-dracula-purple"
        {@opts}
      ><%= Form.input_value(@form, @field) %></textarea>
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  @doc "Fluxon-styled checkbox"
  def checkbox_field(assigns) do
    ~H"""
    <div class="input-group flex items-center gap-2">
      <input
        type="checkbox"
        name={Form.input_name(@form, @field)}
        id={Form.input_id(@form, @field)}
        class="checkbox accent-dracula-purple focus:ring-dracula-purple"
        value="true"
        {@opts}
      />
      <label for={Form.input_id(@form, @field)} class="text-sm font-medium text-white">
        <%= @label || humanize(@field) %>
      </label>
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  # Conditional input group class for error highlighting
  defp form_group_class(form, field) do
    if Keyword.has_key?(form.errors, field), do: "mb-4 input-group has-error", else: "mb-4 input-group"
  end

  defp humanize(field), do: Naming.humanize(field)
end
