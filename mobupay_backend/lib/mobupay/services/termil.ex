defmodule Mobupay.Services.Termil do


  @spec send(atom(), keyword())::{:ok, any} | {:error, any}
  def send(:onboarding_otp, keywords) do
    message = "#{keywords[:otp]} is your mobupay registration code.";

    do_send(keywords[:msisdn], message)

  end


  @spec send(atom(), keyword())::{:ok, any} | {:error, any}
  def send(:funds_transfer_onboarded, keywords) do
    message = "You received NGN3,000 from +2348108125280. Login at https://mobupay.com/+234823726626 to view your balance.";

    do_send(keywords[:msisdn], message)

  end


  @spec send(atom(), keyword())::{:ok, any} | {:error, any}
  def send(:funds_transfer_guest, keywords) do

    message = "You received NGN4,000 from +2348108125280. Visit https://mobupay.com/+234823726626 to claim.";

    do_send(keywords[:msisdn], message)

  end



  defp do_send(_msisdn, message) do
    Process.sleep(4000)

    IO.inspect(message);
    IO.inspect("SMS sent!");
  end
end
