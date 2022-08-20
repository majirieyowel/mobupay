defmodule Mobupay.Helpers.Utility do
  def format_paystack_amount(amount) when is_float(amount) do
    format_paystack_amount(Float.to_string(amount))
  end

  def format_paystack_amount(amount) when is_integer(amount) do
    format_paystack_amount(Integer.to_string(amount))
  end

  def format_paystack_amount(amount) when is_bitstring(amount) do
    {amount, _string} = Float.parse(amount)
    trunc(amount * 100)
  end
end
