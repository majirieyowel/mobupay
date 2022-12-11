defmodule MobupayWhatsapp.Impl.Media do
  alias MobupayWhatsapp.Type
  # alias Mobupay.Whatsapp
  # import MobupayWhatsapp.Impl.Response, only: [invalid_command: 1]

  @spec handle(Type.webhook_media(), map()) :: :ok
  def handle(%{media_url: media_url, msisdn: _msisdn}, _state) do
    IO.inspect(media_url, label: "Media URL")
  end
end
