defmodule Web.CoreComponents do
  @moduledoc """
  Provides core UI components for the admin interface.
  """

  use Phoenix.Component
  import Phoenix.HTML.Form
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a form input with label and error handling.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, :any
  attr :errors, :list, default: []
  attr :required, :boolean, default: false
  attr :help_text, :string, default: nil
  attr :rest, :global

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(assigns) do
    assigns = assign_new(assigns, :value, fn -> "" end)

    ~H"""
    <div class="form-control w-full">
      <label for={@id} class="label">
        <span class="label-text"><%= @label %></span>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={["input input-bordered", @errors != [] && "input-error"]}
        {@rest}
      />
      <%= if @help_text do %>
        <label class="label">
          <span class="label-text-alt"><%= @help_text %></span>
        </label>
      <% end %>
      <%= for error <- @errors do %>
        <label class="label">
          <span class="label-text-alt text-error"><%= error %></span>
        </label>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a modal dialog.
  """
  attr :id, :string, default: "modal"
  attr :show, :boolean, default: true
  attr :on_cancel, :string, default: nil
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div class="modal modal-open">
      <div class="modal-box relative">
        <div class="modal-content">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
      <div class="modal-backdrop" phx-click={@on_cancel}></div>
    </div>
    """
  end

  @doc """
  Renders flash messages.
  """
  attr :flash, :map

  def flash_group(assigns) do
    ~H"""
    <%= if info = live_flash(@flash, :info) do %>
      <div class="alert alert-info mb-4" role="alert" phx-click="lv:clear-flash" phx-value-key="info">
        <%= info %>
      </div>
    <% end %>

    <%= if error = live_flash(@flash, :error) do %>
      <div class="alert alert-error mb-4" role="alert" phx-click="lv:clear-flash" phx-value-key="error">
        <%= error %>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders a button.
  """
  attr :type, :string, default: "button"
  attr :class, :string, default: nil
  attr :label, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :phx_click, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: false

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={["btn", @class]}
      disabled={@disabled}
      phx-click={@phx_click}
      {@rest}
    >
      <%= if @label do %>
        <%= @label %>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  @doc """
  Renders an icon.
  """
  attr :name, :string, required: true
  attr :class, :string, default: "w-4 h-4"

  def icon(assigns) do
    ~H"""
    <svg class={@class}>
      <use href={"/assets/icons/#{@name}.svg#icon"}></use>
    </svg>
    """
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
