defmodule MobupayWhatsapp.Action.Validation do
  @doc """
  Validates amount
  """
  @spec validate_amount(String.t()) :: {:ok, any} | {:error, any}
  def validate_amount(amount) do
    with {:ok, true} <- contains_only_numbers(Regex.match?(~r/^\d+$/, amount)) do
      {:ok, amount}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp contains_only_numbers(true), do: {:ok, true}

  defp contains_only_numbers(false) do
    reason = ~s"""
    Please enter a valid amount\rOnly digits allowed \r_e.g 400_
    """

    {:error, reason}
  end
end
