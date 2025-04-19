defmodule Web.Components.PetalHelpers do
  @moduledoc """
  Helper functions that provide access to Petal Components
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component

      # Import Phoenix base functionality
      import Phoenix.Component
      alias Phoenix.LiveView.JS
      import Phoenix.LiveView.Helpers

      # Define our helpers that delegate to Petal.Components
      # Import core Phoenix components but prefix with ph_
      # Base components
      defdelegate ph_button(assigns), to: Petal.Components, as: :button
      defdelegate ph_badge(assigns), to: Petal.Components, as: :badge
      defdelegate ph_icon(assigns), to: Petal.Components, as: :icon
      defdelegate ph_card(assigns), to: Petal.Components, as: :card
      defdelegate ph_dropdown(assigns), to: Petal.Components, as: :dropdown
      defdelegate ph_dropdown_menu_item(assigns), to: Petal.Components, as: :dropdown_menu_item
      defdelegate ph_field(assigns), to: Petal.Components, as: :field
      defdelegate ph_form(assigns), to: Petal.Components, as: :form
      defdelegate ph_heading(assigns), to: Petal.Components, as: :heading
      defdelegate ph_link(assigns), to: Petal.Components, as: :link
      defdelegate ph_loading(assigns), to: Petal.Components, as: :loading
      defdelegate ph_modal(assigns), to: Petal.Components, as: :modal
      defdelegate ph_table(assigns), to: Petal.Components, as: :table
      defdelegate ph_tab(assigns), to: Petal.Components, as: :tab
      defdelegate ph_tabs(assigns), to: Petal.Components, as: :tabs

      # Table components
      defdelegate ph_pagination(assigns), to: Petal.Components, as: :pagination

      # Form components
      defdelegate ph_input(assigns), to: Petal.Components, as: :input
      defdelegate ph_email_input(assigns), to: Petal.Components, as: :email_input
      defdelegate ph_number_input(assigns), to: Petal.Components, as: :number_input
      defdelegate ph_password_input(assigns), to: Petal.Components, as: :password_input
      defdelegate ph_search_input(assigns), to: Petal.Components, as: :search_input
      defdelegate ph_select(assigns), to: Petal.Components, as: :select
      defdelegate ph_textarea(assigns), to: Petal.Components, as: :textarea
      defdelegate ph_checkbox(assigns), to: Petal.Components, as: :checkbox
      defdelegate ph_radio_group(assigns), to: Petal.Components, as: :radio_group
      defdelegate ph_toggle(assigns), to: Petal.Components, as: :toggle
    end
  end
end
