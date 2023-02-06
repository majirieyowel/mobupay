defmodule MobupayWhatsapp.Entrypoint do
  use MobupayWeb, :controller

  @task_sup Mobupay.TaskSupervisor

  alias MobupayWhatsapp.Dispatcher
  alias Mobupay.Account

  require Logger

  # whatsapp entrypoint
  # profile name
  # msisdn (identifier)
  # message
  def start(conn, %{"WaId" => identifier} = params) do
    Logger.info("Received whatsapp webhook with details: #{inspect(params)}")

    Task.Supervisor.async(@task_sup, fn ->
      Dispatcher.entry(params, Account.get_by_msisdn(identifier))
    end)

    ack(conn)
  end

  # Verifies a users email
  def verify_email(conn, %{"token" => token}),
    do: MobupayWhatsapp.Impl.Onboard.verify_email(conn, token)

  defp ack(conn) do
    conn
    |> put_status(:ok)
    |> put_resp_content_type("application/json")
    |> json(%{
      status: "ok"
    })
  end
end
