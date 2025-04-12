defmodule Web.ErrorViewTest do
  use Web.ConnCase, async: true

  # ✅ Replaces deprecated Phoenix.View
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(Web.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(Web.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
