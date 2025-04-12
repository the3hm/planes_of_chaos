defmodule Web.API.Link do
  @moduledoc """
  Represents a hypermedia link for API responses.

  Includes `:rel` (the relation, like `:self`, `:next`) and `:href` (the absolute or relative URL).
  """

  @derive Jason.Encoder
  defstruct [:href, :rel]
end
