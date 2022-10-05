defmodule Mobupay.Helpers.Response do
  import Plug.Conn, only: [put_status: 2, put_resp_content_type: 2]
  import Phoenix.Controller, only: [json: 2]

  def ok(conn, data \\ %{}, status \\ :ok, _message \\ "successful") do
    conn
    |> put_status(status)
    |> put_resp_content_type("application/json")
    |> json(%{
      status: true,
      data: data
      # message: message
    })
  end

  def error(
        conn,
        status \\ :internal_server_error,
        message \\ "Something is not right!",
        error \\ %{}
      ) do
    conn
    |> put_status(status)
    |> put_resp_content_type("application/json")
    |> json(error_format(message, error))
  end

  def ecto_changeset_error(conn, changeset) do
    error =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts
          |> Keyword.get(String.to_existing_atom(key), key)
          |> to_string()
        end)
      end)

    conn
    |> put_status(:unprocessable_entity)
    |> put_resp_content_type("application/json")
    |> json(error_format("Form contians errors", error))
  end

  defp error_format(message, error) do
    %{
      status: false,
      message: "#{message}",
      error: error
    }
  end
end
