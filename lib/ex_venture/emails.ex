defmodule ExVenture.Emails do
  @moduledoc false

  import Swoosh.Email
  import Web.Gettext, only: [gettext: 1]

  alias ExVenture.Mailer
  alias Web.Router.Helpers, as: Routes
  alias Web.Endpoint

  def welcome_email(user) do
    confirm_url = Routes.confirmation_url(Endpoint, :confirm, code: user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Welcome to #{gettext("ExVenture")}!")
    |> render_body("welcome.html", confirm_url: confirm_url)
    |> Mailer.deliver()
  end

  def verify_email(user) do
    confirm_url = Routes.confirmation_url(Endpoint, :confirm, code: user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Please verify your email address")
    |> render_body("verify_email.html", confirm_url: confirm_url)
    |> Mailer.deliver()
  end

  def password_reset(user) do
    reset_url = Routes.registration_reset_url(Endpoint, :edit, token: user.password_reset_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Password reset for #{gettext("ExVenture")}")
    |> render_body("password_reset.html", reset_url: reset_url)
    |> Mailer.deliver()
  end

  defp render_body(email, template, assigns) do
    html = Web.EmailView.render_to_string(template, assigns)

    text =
      Web.EmailView.render_to_string(template |> String.replace_suffix(".html", ".txt"), assigns)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
