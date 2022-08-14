defmodule Mobupay.Helpers.Utility do
  def format_paystack_amount(amount, multiplier) when is_bitstring(amount) do
    {amount, _string} = Float.parse(amount)
    trunc(amount * multiplier)
  end
end
