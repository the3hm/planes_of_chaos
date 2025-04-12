defmodule Web.FormComponents do
  @moduledoc """
  Tailwind-styled form inputs as reusable Phoenix function components.

  These can be used in HEEx templates like:

      <.text_field form={@form} field={:email} label="Email" />
  """

  use Phoenix.Component

  import Phoenix.HTML.Tag
  import Phoenix.HTML.Safe
  import Web.Gettext
  import Web.ErrorComponents, only: [error_tag: 1]

  alias Phoenix.HTML.Form
  alias Phoenix.Naming

  attr :form, :any, required: true
  attr :field, :atom, required: true
  attr :label, :string, default: nil
  attr :type, :string, default: "text"
  attr :opts, :global

  @doc "Text field input"
  def text_field(assigns) do
    ~H"""
    <div class={form_group_class(@form, @field)}>
      <label class="label" for={Form.input_id(@form, @field)}><%= @label || humanize(@field) %></label>
      <input
        type={@type}
        name={Form.input_name(@form, @field)}
        id={Form.input_id(@form, @field)}
        value={Form.input_value(@form, @field)}
        class="input"
        {@opts}
      />
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  attr :rows, :integer, default: 5

  @doc "Textarea field input"
  def textarea_field(assigns) do
    ~H"""
    <div class={form_group_class(@form, @field)}>
      <label class="label" for={Form.input_id(@form, @field)}><%= @label || humanize(@field) %></label>
      <textarea
        name={Form.input_name(@form, @field)}
        id={Form.input_id(@form, @field)}
        class="input"
        rows={@rows}
        {@opts}
      ><%= Form.input_value(@form, @field) %></textarea>
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  @doc "Checkbox field"
  def checkbox_field(assigns) do
    ~H"""
    <div class="input-group">
      <label class="label font-bold">
        <input
          type="checkbox"
          name={Form.input_name(@form, @field)}
          id={Form.input_id(@form, @field)}
          value="true"
          class="checkbox"
          {@opts}
        />
        <%= @label || humanize(@field) %>
      </label>
      <.error_tag form={@form} field={@field} />
    </div>
    """
  end

  defp form_group_class(form, field) do
    if Keyword.has_key?(form.errors, field), do: "input-group error", else: "input-group"
  end

  defp humanize(field), do: Naming.humanize(field)
end
