defmodule MobupayWhatsapp.Impl.Response do
  alias Mobupay.Services.Twilio

  @spec invalid_command(String.t()) :: :ok
  def invalid_command(msisdn) do
    message = ~s"""
    ⚠️ Invalid command entered
    """

    Twilio.send_whatsapp(msisdn, message)
    :ok
  end

  def enter_msisdn(msisdn) do
    resp_message = ~s"""
      NEXT: \r
      Enter the recipients whatsapp number or share the contact with this page \n
      """

      Twilio.send_whatsapp(msisdn, resp_message)
  end
end
