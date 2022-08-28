defmodule MobupayWeb.Plugs.ValidateHashHeader do
  import Plug.Conn

  alias Mobupay.Helpers.{Response, Encryption}
  alias Mobupay.Services.Redis

  def init(default), do: default

  def call(%Plug.Conn{params: %{"msisdn" => msisdn}} = conn, _default) do
    with {:ok, %{"_hash" => msisdn_hash}} <- Redis.get_map(msisdn),
         [hash] <- get_req_header(conn, "_hash"),
         endcoded_hash <- Encryption.hash(hash),
         true <- msisdn_hash === endcoded_hash do
      conn
    else
      _error ->
        conn
        |> Response.error(400, "Continue onboarding from the same device")
        |> halt()
    end
  end

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> Response.error(400, "Phone number is required")
    |> halt()

    conn
  end
end
