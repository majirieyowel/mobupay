defmodule MobupayWeb.BusinessController do
  use MobupayWeb, :controller

  alias Mobupay.Helpers.{Response, Token}
  alias Mobupay.Businesses
  require Logger



  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
      Logger.info("Received request to create business account with details #{inspect(params)}")

    with {:ok, %Businesses.Business{} = business} <-
           Businesses.create_business(user, params) do
      conn
      |> Response.ok(%{
        business: business
      }, 201)
    else
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> Response.ecto_changeset_error(changeset)

      error ->
        Logger.error(
          "Business creation failed for user: #{inspect(user.id)} with response #{inspect(error)}"
        )

        conn
        |> Response.error(:bad_request)
    end
  end

end
