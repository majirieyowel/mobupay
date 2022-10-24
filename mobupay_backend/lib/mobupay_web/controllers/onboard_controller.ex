defmodule MobupayWeb.OnboardController do
  use MobupayWeb, :controller

  alias Mobupay.Account
  alias Mobupay.Services.{Redis, Twilio}
  alias Mobupay.Helpers.{Response, Token, Encryption, Msisdn, CountryData}

  require Logger

  plug MobupayWeb.Plugs.ValidateHashHeader when action in [:verify_otp, :set_password]

  # 10 mins
  @onboard_otp_expiration 600

  @onboard_key_identifier "_onboarding_otp_"

  def getting_started(conn, _params), do: conn |> Response.ok(CountryData.get_list())

  def check_msisdn(conn, %{"msisdn" => msisdn, "country" => country} = params) do
    Logger.info("Received request to check MSISDN: #{msisdn}, Country: #{country}")

    with {:ok, onboard_status} <- get_onboard_status(params) do
      conn
      |> Response.ok(onboard_status)
    else
      {:error, response} ->
        Logger.error(
          "Request to check msisdn with payload: #{inspect(params)} failed with response #{response}"
        )

        conn
        |> Response.error(400, response)

      error ->
        Logger.error(
          "Request to check msisdn with payload: #{inspect(params)} failed with response #{inspect(error)}"
        )

        conn
        |> Response.error(500, "Unable to process details: #{msisdn} - #{country}")
    end
  end

  def partial_onboard(conn, %{"msisdn" => request_msisdn, "country" => country} = user_params) do
    Logger.info("Received request to create user with details #{inspect(user_params)}")

    random_token = Token.generate(:random)

    encoded_random_token = Encryption.hash(random_token)

    with {:ok, formatted_msisdn} <- Msisdn.format(country, request_msisdn),
         {:ok, currency} <- CountryData.get_currency(country),
         updated_user_params <- Map.put(user_params, "msisdn", formatted_msisdn),
         %Ecto.Changeset{valid?: true, changes: %{msisdn: msisdn} = changes} <-
           Account.partial_onboard(updated_user_params),
         {:ok, _data} <- Twilio.lookup(msisdn),
         updated_changes <- Map.put(changes, "onboard_step", "verify_otp"),
         updated_changes <- Map.put(updated_changes, "_hash", encoded_random_token),
         updated_changes <- Map.put(updated_changes, "currency", currency),
         {:ok, "OK"} <- Redis.set(msisdn, updated_changes),
         {:ok, _otp} <- generate_and_send_onboarding_otp(msisdn) do
      conn
      |> Response.ok(%{
        "_hash" => random_token,
        "msisdn" => formatted_msisdn
      })
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        conn
        |> Response.ecto_changeset_error(changeset)

      {:error, message} ->
        conn
        |> Response.error(400, message)

      error ->
        Logger.error(
          "Partial onboarding failed for user: #{inspect(user_params)} with response #{inspect(error)}"
        )

        conn
        |> Response.error(500, "Server error")
    end
  end

  @spec resend_otp(Plug.Conn.t(), any) :: Plug.Conn.t()
  def resend_otp(conn, %{"msisdn" => msisdn}) do
    Logger.info("Received request to resend onboarding OTP to #{msisdn}")

    case Redis.get_map(msisdn) do
      {:ok, nil} ->
        conn |> Response.error(404, "User (#{msisdn}) not found")

      {:ok, %{"onboard_step" => "verify_otp"}} ->
        generate_and_send_onboarding_otp(msisdn)

        conn |> Response.ok()

      _ ->
        conn |> Response.error(400, "Unable to resend OTP to #{msisdn}")
    end
  end

  def resend_otp(conn, _) do
    conn
    |> Response.error(400, "Missing input")
  end

  def verify_otp(conn, %{"msisdn" => msisdn, "otp" => otp} = params) do
    Logger.info("Received request to verify onboarding OTP with params #{inspect(params)}")

    case Redis.get(msisdn <> @onboard_key_identifier <> otp) do
      {:ok, nil} ->
        conn
        |> Response.error(404, "Invalid/Expired OTP")

      {:ok, _otp} ->
        with {:ok, %{"onboard_step" => "verify_otp"} = partial_user} <- Redis.get_map(msisdn),
             updated_step <- %{partial_user | "onboard_step" => "authentication_method"},
             {:ok, "OK"} <- Redis.set(msisdn, updated_step) do
          conn
          |> Response.ok()
        else
          error ->
            Logger.error("Verifying OTP for #{msisdn} failed with reason: #{inspect(error)}")

            conn
            |> Response.error(400, "Unable to verify OTP at this time")
        end
    end
  end

  def verify_otp(conn, _) do
    conn
    |> Response.error(400, "Missing input")
  end

  def set_password(conn, %{"msisdn" => msisdn, "password" => password} = params) do
    Logger.info("Received request to set password method with params: #{inspect(params)}")

    with {:ok, %{"onboard_step" => "authentication_method"} = partial_user} <-
           Redis.get_map(msisdn),
         u_partial_user <-
           Map.put(partial_user, "ref", Token.generate_unique(:user_ref))
           |> Map.put("password", password),
         {:ok, %Account.User{}} <-
           Account.full_onboard(u_partial_user),
         {:ok, _resp} <- Redis.del(msisdn) do
      conn
      |> Response.ok()
    else
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> Response.ecto_changeset_error(changeset)

      error ->
        Logger.error("set_password/2 with params #{params} failed with reason: #{inspect(error)}")

        conn
        |> Response.error(400, "Unable to set password at this time")
    end
  end

  # TODO: verify this is useful
  def set_auth_method(conn, _) do
    conn
    |> Response.error(400, "Missing/Invalid input")
  end

  defp generate_and_send_onboarding_otp(msisdn) do
    with otp <- Token.generate(:otp),
         {:ok, _key} <-
           Redis.set_with_expiration(
             msisdn <> @onboard_key_identifier <> otp,
             otp,
             @onboard_otp_expiration
           ) do
      # async
      Task.Supervisor.async_nolink(Mobupay.TaskSupervisor, fn ->
        message = "#{otp} is your roundup registration code."
        IO.inspect(self(), label: "Process: ")
        IO.inspect(message)
        # Twilio.send(msisdn, message)
      end)

      {:ok, otp}
    else
      error ->
        Logger.error("generate_and_send_onboarding_otp/1 fails with error: #{inspect(error)}")
        {:error, "Unable to generate OTP"}
    end
  end

  defp get_onboard_status(%{"msisdn" => msisdn, "country" => _country}) do
    with {:ok, full_onboard} <- check_full_onboard(msisdn),
         {:ok, partial_onboard, partial_user} <- check_partial_onboard(msisdn),
         {:ok, onboard_step} <- check_onboard_step(partial_user) do
      {:ok,
       %{
         full_onboard?: full_onboard,
         partial_onboard?: partial_onboard,
         onboard_step: onboard_step
       }}
    else
      error ->
        Logger.error("get_onboard_status/1 has failed with error #{error}")
        {:error, error}
    end
  end

  defp check_full_onboard(msisdn) do
    case Account.get_by_msisdn(msisdn) do
      %Account.User{} ->
        {:ok, true}

      nil ->
        {:ok, false}
    end
  end

  defp check_partial_onboard(msisdn) do
    case Redis.get_map(msisdn) do
      {:ok, nil} ->
        {:ok, false, %{}}

      {:ok, value} ->
        {:ok, true, value}
    end
  end

  defp check_onboard_step(%{"onboard_step" => onboard_step}), do: {:ok, onboard_step}

  defp check_onboard_step(_), do: {:ok, nil}
end
