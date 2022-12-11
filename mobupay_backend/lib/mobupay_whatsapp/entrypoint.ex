defmodule MobupayWhatsapp.Entrypoint do
  use MobupayWeb, :controller

  @task_sup Mobupay.TaskSupervisor

  alias MobupayWhatsapp.Impl
  alias Mobupay.Whatsapp

  require Logger

  # TODO sanitize message body using plug
  # TODO: mainenance mode plug
  # TODO: Trim emojis and others
  # TODO: Messages to lowercase

  # def index(conn, %{"WaId" => msisdn} = params) do
  #   email = "majirieyowel@gmail.com"
  #   profile_name = "Mj"

  #   message = ~s"""
  #   Almost done #{profile_name}, \n
  #   A verification link has been sent to your email: *#{email}* \r
  #   Please verify your email so we know it's you. \n
  #   (_respond with number_)
  #   1. Resend verification link \r
  #   2. Use another email \r
  #   """
  #   Mobupay.Services.Twilio.send_whatsapp(msisdn, message)

  #   conn
  #   |> put_status(:ok)
  #   |> put_resp_content_type("application/json")
  #   |> json(%{
  #     status: "ok"
  #   })
  # end

  # Requests that come in through the webhook
  def index(conn, %{"WaId" => msisdn} = params) do
    Task.Supervisor.async(@task_sup, fn ->
      pre_dispatch(params, get_state(msisdn))
    end)

    ok_response(conn)
  end

  # something critical went wrong bro
  def index(conn, params) do
    Logger.error("Unable to parse webhook format: #{inspect(params)}")

    ok_response(conn)
  end

  # Verifies a users email
  def verify_email(conn, %{"token" => token}) do
    state = Whatsapp.get_state_by_confirmation_token(token)

    case state do
      %Whatsapp.State{msisdn: msisdn, state_action: "awaiting_email_confirmation", email: email} ->
        Whatsapp.update(state, %{
          email_confirmation_token: nil,
          state: "idle",
          state_action: nil
        })

        message = "Your email (#{email}) has been confirmed successfully! 🥳"

        message = ~s"""
        Your email (#{email}) has been confirmed successfully! 🥳 \n
        Send \"help\" for instructions on how to use Mobupay.
        """

        Mobupay.Services.Twilio.send_whatsapp(msisdn, message)

        conn
        |> put_status(:ok)
        |> put_resp_content_type("application/json")
        |> json(%{
          confirmed: true
        })

      _ ->
        conn
        |> put_status(:ok)
        |> put_resp_content_type("application/json")
        |> json(%{
          confirmed: false
        })
    end
  end

  # middleware to catch special keywords like - help, cancel
  defp pre_dispatch(%{"Body" => message, "WaId" => msisdn} = params, state) do
    IO.inspect(params, label: "Params: ")
    IO.inspect(state, label: "State: ")

    if(Regex.match?(~r/^help/, message),
      do: Impl.Help.handle(msisdn),
      else: dispatch(params, state)
    )
  end

  # initiate user onboarding first time
  defp dispatch(%{"Body" => message, "WaId" => msisdn, "ProfileName" => profile_name}, nil) do
    Impl.Onboard.handle(
      %{
        msisdn: msisdn,
        message: message,
        profile_name: profile_name
      },
      nil
    )
  end

  # continue user onboarding
  defp dispatch(
         %{"Body" => message, "WaId" => msisdn, "ProfileName" => profile_name},
         %Whatsapp.State{state: "onboarding"} = state
       ) do
    Impl.Onboard.handle(
      %{
        msisdn: msisdn,
        message: message,
        profile_name: profile_name
      },
      state
    )
  end

  # process incoming message
  defp dispatch(
         %{
           "NumMedia" => "0",
           "Body" => message,
           "WaId" => msisdn,
           "ProfileName" => profile_name
         },
         %Whatsapp.State{} = state
       ) do
    Impl.Message.handle(
      %{
        msisdn: msisdn,
        message: message,
        profile_name: profile_name
      },
      state
    )
  end

  # process only one vcf media
  defp dispatch(
         %{
           "NumMedia" => media_count,
           "MediaUrl0" => media_url,
           "WaId" => msisdn,
           "ProfileName" => profile_name
         },
         %Whatsapp.State{} = state
       )
       when media_count == 1 do
    Impl.Media.handle(
      %{
        msisdn: msisdn,
        media_url: media_url,
        profile_name: profile_name
      },
      state
    )
  end

  #TODO: Only allow one media file

  # TODO fetches the state from state or cache
  defp get_state(msisdn) do
    Whatsapp.get_by_msisdn(msisdn)
  end

  defp ok_response(conn) do
    conn
    |> put_status(:ok)
    |> put_resp_content_type("application/json")
    |> json(%{
      status: "ok"
    })
  end
end
