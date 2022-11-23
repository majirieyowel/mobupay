defmodule MobupayWeb.PageController do
  use MobupayWeb, :controller
  alias Mobupay.Helpers.Response

  def index(conn, _paprams) do
    conn
    |> Response.ok(%{
      "message" => "Welcome to mobupay API",
      "version" => "0.1"
    })
  end
end
