defmodule Mobupay.Businesses do
  @moduledoc """
  The Business context.
  """

  alias Mobupay.Helpers.{Token}
  alias Mobupay.Businesses.{Business}
  alias Mobupay.Account

  import Ecto.Query, warn: false
  alias Mobupay.Repo

  def business_name_exists?(user_id, business_name) do
    Business
    |> where([b], b.name == ^business_name)
    |> where([b], b.user_id == ^user_id)
    |> Repo.exists?()
  end

  def create_business(%Account.User{id: user_id} = user, params) do
    params =
      Map.put(params, "ref", Token.generate(:random))
      |> Map.put("user_id", user_id)

    changeset =
      user
      |> Ecto.build_assoc(:businesses)
      |> Business.changeset(params)

    Repo.insert(changeset)
  end
end
