defmodule MobupayWhatsapp.Impl.Message do
  alias MobupayWhatsapp.Type
  alias Mobupay.Whatsapp
  import MobupayWhatsapp.Impl.Response, only: [invalid_command: 1]

  require Logger

  @actions ~w(send request)

  @spec handle(Type.webhook_message(), map()) :: :ok
  def handle(%{message: message} = params, state) do
    action = get_action_part(message)

    if(Enum.member?(@actions, action),
      do: process_action(action, params, state),
      else: maybe_resume_from_state(params, state)
    )
  end

  defp get_action_part(string) do
    [head | _tail] = String.split(string, " ")
    head |> String.downcase()
  end

  defp process_action(action, params, state) do
    apply(
      String.to_existing_atom("Elixir.MobupayWhatsapp.Action.#{String.capitalize(action)}"),
      :handle,
      [
        params,
        state
      ]
    )
  end

  defp maybe_resume_from_state(
         %{message: message, msisdn: msisdn} = params,
         %Whatsapp.State{state: state_action} = state
       ) do
    if(Enum.member?(@actions, String.downcase(state_action)),
      do: process_action(state_action, params, state),
      else: respond_with_ai(msisdn, message)
    )
  end

  defp respond_with_ai(msisdn, _message) do
    Logger.info("Responding with AI")
    invalid_command(msisdn)
    :ok
  end
end
