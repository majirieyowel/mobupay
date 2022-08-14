defmodule Mobupay.Guardian.Pipeline do
  @moduledoc """
  Guardian pipeline
  """
  use Guardian.Plug.Pipeline,
    otp_app: :mobupay,
    module: Mobupay.Guardian,
    error_handler: Mobupay.Guardian.ErrorHandler

  @claims %{typ: "access"}

  plug(Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, ensure: true)
end
