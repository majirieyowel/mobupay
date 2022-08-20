defmodule MobupayWeb.Plugs.ValidateRequestMsisdn do
  import Plug.Conn

  alias Mobupay.Helpers.Response

  def init(default), do: default

  def call(%Plug.Conn{params: %{"country" => _country, "msisdn" => msisdn}} = conn, _default) do
    IO.inspect(msisdn, label: "Called from plug")

    conn
    |> Response.ok(%{
      full_onboard?: "Fish"
    })
    |> halt()

    conn
  end

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> Response.ok(%{
      full_onboard?: "Nothing"
    })
    |> halt()

    conn
  end
end
