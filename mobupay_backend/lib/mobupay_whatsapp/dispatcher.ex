defmodule MobupayWhatsapp.Dispatcher do
  @moduledoc """
  Functionality to parse and dispatch messages to handlers
  """
  import MobupayWhatsapp.Helpers

  alias MobupayWhatsapp.Impl
  alias Mobupay.Account

  def entry(%{"Forwarded" => "true", "WaId" => msisdn}, _state) do
    message = lang("yoruba", "global", :no_fowarded_messages)

    whatsapp_feedback(msisdn, message)
  end

  # Middleware of some sort to handle certain special commands like: help, balance, status etc.
  def entry(%{"Body" => message, "WaId" => msisdn} = params, state) do
    IO.inspect(params, label: "Params: ")
    IO.inspect(state, label: "State: ")

    cond do
      Regex.match?(~r/^help/, message) ->
        Impl.Help.handle(msisdn)

      Regex.match?(~r/^balance/, message) ->
        Impl.Balance.handle(msisdn)

      true ->
        handle(%{params | "Body" => message |> String.downcase() |> String.trim()}, state)
    end
  end

  # At this point the user has no account
  # and probably the first time sending a message.
  defp handle(%{"Body" => message, "WaId" => msisdn, "ProfileName" => profile_name}, nil) do
    Impl.Onboard.handle(
      %{
        msisdn: msisdn,
        message: message,
        profile_name: profile_name
      },
      nil
    )
  end

  # At this point the user has registered their phone number and has state
  # The user is also still onboarding
  defp handle(
         %{"Body" => message, "WaId" => msisdn, "ProfileName" => profile_name},
         %Account.User{state: "onboarding"} = state
       ) do
    Impl.Onboard.handle(
      %{
        msisdn: msisdn,
        message: message,
        profile_name: profile_name
      },
      state
    )
  end
end
