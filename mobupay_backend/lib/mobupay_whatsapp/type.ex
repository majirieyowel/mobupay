defmodule MobupayWhatsapp.Type do
  @type state :: :idle | :onboarding | :sending

  @type state_actions :: :awaiting_email

  @type webhook_message :: %{
          msisdn: String.t(),
          message: String.t(),
          profile_name: String.t()
        }

  @type webhook_media :: %{
          media_url: String.t(),
          msisdn: String.t(),
          profile_name: String.t()
        }
end
