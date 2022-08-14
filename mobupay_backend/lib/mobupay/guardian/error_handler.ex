defmodule Mobupay.Guardian.ErrorHandler do
  @moduledoc """
  Guardian Error Handler
  """
  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler

  def auth_error(conn, {_type, _reason}, _opts) do
    conn |> Mobupay.Helpers.Response.error(401, "Authenticaton failed")
  end
end
