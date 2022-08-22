defmodule Mobupay.Helpers.Utility do
  def remove_decimal(amount) when is_float(amount) do
    remove_decimal(Float.to_string(amount))
  end

  def remove_decimal(amount) when is_integer(amount) do
    remove_decimal(Integer.to_string(amount))
  end

  def remove_decimal(amount) when is_bitstring(amount) do
    {amount, _string} = Float.parse(amount)
    trunc(amount * 100)
  end
end
