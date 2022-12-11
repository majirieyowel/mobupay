defmodule MobupayWhatsapp.Action.Send do
  alias MobupayWhatsapp.Type
  alias Mobupay.Whatsapp
  alias Mobupay.Services.Twilio
  alias Mobupay.Helpers.Utility

  import MobupayWhatsapp.Action.Validation, only: [validate_amount: 1]
  import MobupayWhatsapp.Impl.Response, only: [enter_msisdn: 1]

  @state_param %{
    amount: "",
    email: "",
    to_msisdn: "",
    from_msisdn: ""
  }

  @spec handle(Type.webhook_message(), map()) :: :ok
  def handle(
        %{message: message} = params,
        %Whatsapp.State{state: current_state} = state
      ) do
    cond do
      String.trim(message) == "cancel" ->
        cancel(state)

      current_state == "Send" ->
        continue(params, state)

      true ->
        [_head | commands] = String.split(message, " ")

        send(commands, params, state)
    end
  end

  # Cancel this process
  @spec cancel(%Whatsapp.State{}) :: :ok
  def cancel(%Whatsapp.State{msisdn: msisdn} = state) do
    Whatsapp.update(state, %{
      state: "idle",
      state_action: nil,
      state_param: nil
    })

    message = ~s"""
    Send operation has been canceled ✅
    """

    Twilio.send_whatsapp(msisdn, message)
  end

  # Send >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  # triggered by "[]"
  def send([], %{profile_name: profile_name, msisdn: msisdn}, state) do
    Whatsapp.update(state, %{
      state: "Send",
      state_action: "awaiting_amount",
      state_param: @state_param
    })

    message = ~s"""
    Ok #{profile_name}, How much do you want to send? \n
    _e.g 500_ \n

    Note: \r
    _Text "cancel" to stop this transaction._
    """

    Twilio.send_whatsapp(msisdn, message)
  end

  # triggered by "400"
  def send(
        [amount],
        %{msisdn: msisdn},
        state
      ) do
    with {:ok, amount} <- validate_amount(amount),
         amount_formatted <- Utility.remove_decimal(amount) do
      Whatsapp.update(state, %{
        state: "Send",
        state_action: "awaiting_msisdn",
        state_param: %{@state_param | amount: amount_formatted}
      })

      enter_msisdn(msisdn)

    else
      {:error, reason} ->
        Twilio.send_whatsapp(msisdn, reason)
    end
  end

  # triggered by "400 to"
  def send([_amount, "to"], _params, _state) do
    IO.inspect(binding())
  end

  # triggered by "400 08108125270"
  def send([_amount, _msisdn], _params, _state) do
    IO.inspect(binding())
  end

  # triggered by "400 to 08108125270"
  def send([_amount, "to", _msisdn], _params, _state) do
    IO.inspect(binding())
  end

  # Continue >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  # expects amount to be the input e.g "400"
  def continue(
        %{message: message, msisdn: msisdn},
        %Whatsapp.State{state_action: "awaiting_amount", state_param: state_param} = state
      ) do
    with {:ok, amount} <- validate_amount(message),
         amount_formatted <- Utility.remove_decimal(amount) do
      Whatsapp.update(state, %{
        state_action: "awaiting_msisdn",
        state_param: %{state_param | "amount" => amount_formatted}
      })

      enter_msisdn(msisdn)
    else
      {:error, reason} ->
        Twilio.send_whatsapp(msisdn, reason)
    end
  end

  # expects msisdn
  def continue(
        %{message: message, msisdn: _msisdn},
        %Whatsapp.State{state_action: "awaiting_msisdn", state_param: _state_param} = _state
      ) do

        
    IO.inspect(message, label: "Requires MSISDN")
  end
end
