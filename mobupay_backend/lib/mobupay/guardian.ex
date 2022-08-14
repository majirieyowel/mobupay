defmodule Mobupay.Guardian do
  use Guardian, otp_app: :mobupay

  alias Mobupay.Account

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => id}), do: {:ok, Account.get_user!(id)}
  def resource_from_claims(_), do: {:error, "Unknown resource type"}

  def generate_token(user) do
    with {:ok, access_token, claims} <-
           encode_and_sign(user, %{}, token_type: :access, ttl: {7, :days}),
         {:ok, refresh_token, _claims} <-
           encode_and_sign(user, %{}, token_type: :refresh, ttl: {30, :days}) do
      {:ok, access_token, refresh_token, claims}
    else
      _error ->
        {:error, :unauthorized}
    end
  end
end
