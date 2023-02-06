defmodule MobupayWhatsapp.Impl.Onboard do
  alias Mobupay.Account

  import MobupayWhatsapp.Helpers

  alias Mobupay.Helpers.Token

  alias Mobupay.Services.Mailgun

  def verify_email(conn, token) do
    state = Account.get_state_by_confirmation_token(token)

    case state do
      %Account.User{
        msisdn: msisdn,
        state_action: "awaiting_email_confirmation",
        email: email,
        language: language
      } ->
        Account.update(state, %{
          email_confirmation_token: nil,
          state: "idle",
          state_action: nil
        })

        message = lang(language, "onboarding", :email_verified, [email])

        Mobupay.Services.Twilio.send_whatsapp(msisdn, message)

        verify_email_http_response(conn, %{
          confirmed: true
        })

      _ ->
        verify_email_http_response(conn, %{
          confirmed: false
        })
    end
  end

  # when user is onboarding for the first time
  def handle(%{msisdn: msisdn}, nil) do
    # create new state without email
    Account.create(%{
      msisdn: msisdn,
      ref: Token.generate_unique(:user_ref),
      state: "onboarding",
      state_action: "select_language"
    })

    prompt_langage(msisdn)
  end

  # User us supposed to select a language here
  def handle(
        %{
          msisdn: msisdn,
          message: message,
          profile_name: profile_name
        } = params,
        %{state: "onboarding", state_action: "select_language"} = state
      ) do
    cond do
      message == "1" || message == "english" ->
        {:ok, %Account.User{language: language}} =
          Account.update(state, %{
            language: "english",
            state_action: "awaiting_email"
          })

        message = lang(language, "onboarding", :welcome_message, [profile_name])
        whatsapp_feedback(msisdn, message)

      message == "2" || message == "yoruba" ->
        {:ok, %Account.User{language: language}} =
          Account.update(state, %{
            language: "yoruba",
            state_action: "awaiting_email"
          })

        message = lang(language, "onboarding", :welcome_message, [profile_name])
        whatsapp_feedback(msisdn, message)

      true ->
        prompt_langage(msisdn)
    end
  end

  # user is supposed to enter email here:
  def handle(
        %{
          msisdn: msisdn,
          message: message
        },
        %{state: "onboarding", state_action: "awaiting_email", language: language} = state
      ) do
    case get_email_from_message(message) do
      [email | _tail] ->
        token = UUID.uuid1()

        Account.update(state, %{
          email: email,
          email_confirmation_token: token,
          state_action: "awaiting_email_confirmation"
        })

        Mailgun.send(email, "Confirm your email address!", "email_verification", %{
          "email" => email,
          "verification_link" => "#{System.get_env("MOBUPAY_FRONTEND_URL")}email-confirm/#{token}"
        })

        message = lang(language, "onboarding", :email_verification_sent, [email])

        whatsapp_feedback(msisdn, message)

      nil ->
        message = lang(language, "onboarding", :email_required_prompt, [])

        whatsapp_feedback(msisdn, message)
    end

    :ok
  end

  # User options for commands while awaiting email confirmation trigger
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
          state_action: "awaiting_email_confirmation",
          language: language
        } = state
      ) do
    message = String.trim(message)

    cond do
      message == "1" ->
        # Resend Email OTP
        Mailgun.send(email, "Confirm your email address!", "email_verification", %{
          "email" => email,
          "verification_link" => "#{System.get_env("MOBUPAY_FRONTEND_URL")}email-confirm/#{token}"
        })

        resp_message = lang(language, "onboarding", :verification_link_resent, [email])

        whatsapp_feedback(msisdn, resp_message)

      message == "2" ->
        # use another email
        Account.update(state, %{
          state_action: "awaiting_email"
        })

        resp_message = lang(language, "onboarding", :new_email_to_use, [email])

        whatsapp_feedback(msisdn, resp_message)

      true ->
        resp_message = lang(language, "onboarding", :verify_email_remind, [email])

        whatsapp_feedback(msisdn, resp_message)
    end

    :ok
  end

  defp prompt_langage(msisdn) do
    message = ~s"""
    Select a language

    1. English
    2. Yoruba
    3. Hausa
    4. Igbo
    """

    whatsapp_feedback(msisdn, message)
  end

  defp verify_email_http_response(conn, data) do
    conn
    |> Plug.Conn.put_status(:ok)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Phoenix.Controller.json(data)
  end

  defp get_email_from_message(message),
    do: Regex.run(~r/[a-zA-z0-9\.]+@[a-zA-z0-9\.]+\.[A-Za-z]+/, message)
end
