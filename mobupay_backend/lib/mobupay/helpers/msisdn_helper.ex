defmodule Mobupay.Helpers.Msisdn do
  @moduledoc false

  require Logger

  def remove_plus(msisdn) do
    case String.starts_with?(msisdn, "+") do
      true ->
        {_, valid_msisdn} = String.split_at(msisdn, 1)
        valid_msisdn

      false ->
        msisdn
    end
  end
end
