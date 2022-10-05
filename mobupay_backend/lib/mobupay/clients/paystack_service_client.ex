defmodule Mobupay.Clients.PaystackServiceClient do
  @moduledoc nil

  @callback verify_transaction(ref :: String.t()) :: {:ok, map()} | {:error, any()}
end
