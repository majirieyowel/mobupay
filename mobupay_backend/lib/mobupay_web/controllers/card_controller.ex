defmodule MobupayWeb.CardController do
  use MobupayWeb, :controller

  alias Mobupay.Account
  alias Mobupay.Helpers.{Response, EC}
  require Logger

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => card_ref}) do
    Logger.info("Received request to delete card with ref: #{inspect(card_ref)}")

    with %Account.Card{} = card <-
           Account.get_user_card_by_ref(user, card_ref),
         {:ok, %Account.Card{}} <- Account.delete_card(card) do
      conn
      |> Response.ok(%{}, :ok, "Card deleted successfully")
    else
      nil ->
        conn
        |> Response.error(404, "Card not found")

      error ->
        Logger.error(
          "Unable to delete card with ref: #{inspect(card_ref)}, Error: #{inspect(error)}"
        )

        conn
        |> Response.error(
          500,
          "E#{EC.get("unhandled_card_removal_error")} - Unable delete card"
        )
    end
  end
end
