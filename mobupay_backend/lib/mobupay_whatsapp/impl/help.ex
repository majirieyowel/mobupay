defmodule MobupayWhatsapp.Impl.Help do
  alias MobupayWhatsapp.Type
  alias Mobupay.Whatsapp
  alias Mobupay.Services.{Twilio, Mailgun}
  alias Mobupay.Helpers.Encryption

  @spec handle(String.t()) :: :ok
  def handle(msisdn) do
    message = ~s"""
    *HELP CENTER* \n
    SEND \r
    Send money to any whatsapp number. \r
    *Example:* \r
    _> send 500 to 08108125270_ \n
    REQUEST \r
    Request money from any whatsapp number. \r
    *Example:* \r
    _> request 500 from 08108125270_ \n
    """

    Twilio.send_whatsapp(msisdn, message)

    :ok
  end
end
