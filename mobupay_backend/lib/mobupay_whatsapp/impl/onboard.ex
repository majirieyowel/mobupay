defmodule MobupayWhatsapp.Impl.Onboard do
  alias MobupayWhatsapp.Type
  alias Mobupay.Whatsapp
  alias Mobupay.Services.{Twilio, Mailgun}

  import MobupayWhatsapp.Impl.Response, only: [invalid_command: 1]

  # when user is onboarding for the first time
  @spec handle(Type.webhook_message(), nil) :: :ok
  def handle(
        %{
          msisdn: msisdn,
          profile_name: profile_name
        },
        nil
      ) do
    # create new state without email
    Whatsapp.create(%{
      msisdn: msisdn,
      state: "onboarding",
      state_action: "awaiting_email"
    })

    message = ~s"""
    Hello #{profile_name} 👋🏾, \n
    Welcome to Mobupay. \r
    With Mobupay you can send and recieve money from any Whatsapp contact, amazing right? 🤩 \r
    To learn more about how mobupay works, watch this short video: https://youtu.be/dQw4w9WgXcQ \n
    *To get started, send us your email address below*  \n\n
    Lets gooooo 🚀
    """

    Twilio.send_whatsapp(msisdn, message)

    :ok
  end

  # user is supposed to send their email here
  def handle(
        %{
          msisdn: msisdn,
          message: message,
          profile_name: profile_name
        } = params,
        %{state: "onboarding", state_action: "awaiting_email"} = state
      ) do
    case get_email_from_message(message) do
      [email | _tail] ->
        token = UUID.uuid1()

        Whatsapp.update(state, %{
          email: email,
          email_confirmation_token: token,
          state_action: "awaiting_email_confirmation"
        })

        Mailgun.send(email, "Confirm your email address!", "email_verification", %{
          "email" => email,
          "verification_link" => "#{System.get_env("MOBUPAY_FRONTEND_URL")}email-confirm/#{token}"
        })

        message = ~s"""
        Almost done #{profile_name}, \n
        A verification link has been sent to your email: *#{email}* \r
        Please verify your email so we know it's you. \n

        (_respond with number_)
        1. Resend verification link \r
        2. Use another email \r

        """

        Twilio.send_whatsapp(msisdn, message)

      nil ->
        options_list = [
          "Please reply with your email address to proceed. we need this to notify you of transactions.",
          "Your email address is required for the next steps.",
          "Please enter your email address below."
        ]

        message = "#{Enum.random(options_list)}"

        Twilio.send_whatsapp(msisdn, message)
    end

    :ok
  end

  # Use options after on awaiting verification message
  def handle(
        %{
          msisdn: msisdn,
          message: message,
          profile_name: profile_name
        } = params,
        %{
          state: "onboarding",
          email: email,
          email_confirmation_token: token,
          state_action: "awaiting_email_confirmation"
        } = state
      ) do
    mesage = String.trim(message)

    cond do
      message == "1" ->
        # Resend Email OTP
        Mailgun.send(email, "Confirm your email address!", "email_verification", %{
          "email" => email,
          "verification_link" => "#{System.get_env("MOBUPAY_FRONTEND_URL")}email-confirm/#{token}"
        })

        resp_message = ~s"""
        The verification link has been resent!. Please check your mail: #{email}
        """

        Twilio.send_whatsapp(msisdn, resp_message)

      message == "2" ->
        # use another email
        Whatsapp.update(state, %{
          state_action: "awaiting_email"
        })

        resp_message = ~s"""
        Please enter another email you will like to use
        """

        Twilio.send_whatsapp(msisdn, resp_message)

      true ->
        invalid_command(msisdn)
    end

    :ok
  end

  defp get_email_from_message(message),
    do: Regex.run(~r/[a-zA-z0-9\.]+@[a-zA-z0-9\.]+\.[A-Za-z]+/, message)
end
