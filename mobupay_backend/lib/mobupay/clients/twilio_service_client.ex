defmodule Mobupay.Clients.TwilioServiceClient do
  @moduledoc nil

  @callback lookup(msisdn :: String.t()) :: {:ok, map()} | {:error, any()}
end
