defmodule MobupayWhatsapp.Helpers do
  alias Mobupay.Services.Twilio

  def whatsapp_feedback(msisdn, message) do
    Twilio.send_whatsapp(msisdn, message)
  end

  def lang(string_path, file, function, other_params \\ []) do
    apply(
      String.to_existing_atom(
        "Elixir.MobupayWhatsapp.Lang.#{String.capitalize(string_path)}.#{String.capitalize(file)}"
      ),
      function,
      other_params
    )
  end
end
