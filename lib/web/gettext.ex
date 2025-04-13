defmodule Web.Gettext do
  @moduledoc """
  Provides gettext-based translation backend for Web.
  """

  use Gettext.Backend, otp_app: :ex_venture
end
