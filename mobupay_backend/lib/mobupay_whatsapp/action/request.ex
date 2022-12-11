defmodule MobupayWhatsapp.Action.Request do
  alias MobupayWhatsapp.Type

  @spec handle(Type.webhook_message(), map()) :: :ok
  def handle(_params, _state) do
    IO.inspect("Request Send")
  end
end
