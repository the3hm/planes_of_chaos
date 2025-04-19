defmodule Web.Admin.UserExportController do
  use Web, :controller

  def export(conn, %{"path" => path}) do
    send_download(conn, {:file, path}, filename: "users.csv")
  end
end
