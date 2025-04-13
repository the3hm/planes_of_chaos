defmodule ExVenture.Emails do
  @moduledoc false

  import Swoosh.Email
  use Gettext, backend: Web.Gettext

  alias ExVenture.Mailer
  alias Web.EmailPaths

  def welcome_email(user) do
    confirm_url = EmailPaths.confirm_url(user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Welcome to #{gettext("ExVenture")}!")
    |> render_body("welcome", confirm_url: confirm_url)
  end

  def verify_email(user) do
    confirm_url = EmailPaths.confirm_url(user.email_verification_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Please verify your email address")
    |> render_body("verify_email", confirm_url: confirm_url)
    |> Mailer.deliver()
  end

  def password_reset(user) do
    reset_url = EmailPaths.reset_url(user.password_reset_token)

    new()
    |> to(user.email)
    |> from({"ExVenture", "no-reply@example.com"})
    |> subject("Password reset for #{gettext("ExVenture")}")
    |> render_body("password_reset", reset_url: reset_url)
    |> Mailer.deliver()
  end

  defp render_body(email, template, assigns) do
    html = Phoenix.Template.render_to_string(Web.EmailView, "#{template}.html", "html", assigns)
    text = Phoenix.Template.render_to_string(Web.EmailView, "#{template}.txt", "text", assigns)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
