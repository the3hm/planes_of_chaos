defmodule ExVenture.Emails do
  @moduledoc false

  import Swoosh.Email
  import Web.Gettext, only: [gettext: 1]

  alias ExVenture.Mailer
  alias Web.Endpoint
  alias Web.Router.Helpers, as: Routes

  def welcome_email(user) do
    confirm_url = Endpoint.url() <> Routes.confirmation_path(Endpoint, :confirm, user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Welcome to #{gettext("ExVenture")}!")
    |> render_body("welcome", confirm_url: confirm_url)
    |> Mailer.deliver()
  end

  def verify_email(user) do
    confirm_url = Endpoint.url() <> Routes.confirmation_path(Endpoint, :confirm, user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Please verify your email address")
    |> render_body("verify_email", confirm_url: confirm_url)
    |> Mailer.deliver()
  end

  def password_reset(user) do
    reset_url = Endpoint.url() <> Routes.registration_reset_path(Endpoint, :edit, user.password_reset_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Password reset for #{gettext("ExVenture")}")
    |> render_body("password_reset", reset_url: reset_url)
    |> Mailer.deliver()
  end

  defp render_body(email, template, assigns) do
    html = Phoenix.View.render_to_string(Web.EmailView, template, assigns)
    text = Phoenix.View.render_to_string(Web.EmailView, template |> String.replace_suffix(".html", ".txt"), assigns)


    email
    |> html_body(html)
    |> text_body(text)
  end
end
