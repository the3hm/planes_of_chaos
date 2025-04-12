defmodule Web.PaginationView do
  @moduledoc """
  Helper functions for pagination rendering and page path generation.
  """

  import Web.Gettext
  alias Web.Router.Helpers, as: Routes

  @doc """
  Builds a full page URL with updated `page` param.

  ## Example

      iex> page_path("/articles?page=2", 4)
      "/articles?page=4"
  """
  def page_path(path, page) do
    uri = URI.parse(path)

    query =
      uri.query
      |> decode_query()
      |> Map.put("page", page)
      |> URI.encode_query()

    %{uri | query: query}
    |> URI.to_string()
  end

  @doc """
  Safely decodes a URI query string into a map.
  """
  def decode_query(nil), do: %{}
  def decode_query(query), do: URI.decode_query(query)

  @doc "Returns a list of previous page numbers to render before the current page."
  def previous_pagination(%{current: 1}), do: []

  def previous_pagination(%{current: current}) do
    1..(current - 1)
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.reverse()
  end

  @doc "Returns true if there are more than 3 pages before the current page."
  def more_previous?(%{current: current}), do: current > 4

  @doc "Returns an empty list if current page is the last page."
  def next_pagination(%{current: current, total: total}) when current == total, do: []

  @doc "Returns a list of up to 3 page numbers after the current page."
  def next_pagination(%{current: current, total: total}) do
    (current + 1)..total
    |> Enum.take(3)
  end

  @doc "Returns true if there are more than 3 pages after the current page."
  def more_next?(%{current: current, total: total}), do: total - current >= 4
end
