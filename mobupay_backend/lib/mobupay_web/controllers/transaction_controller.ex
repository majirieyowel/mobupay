defmodule MobupayWeb.TransactionController do
  use MobupayWeb, :controller

  alias Mobupay.Helpers.{Response, Pagination}
  alias Mobupay.Transactions

  require Logger

  # List user transactions
  def transactions(
        %Plug.Conn{
          assigns: %{current_user: %Mobupay.Account.User{} = user}
        } = conn,
        params
      ) do
    transactions = Transactions.list_user_transactions(user, params)

    conn
    |> Response.ok(Pagination.format("transactions", transactions))
  end
end
