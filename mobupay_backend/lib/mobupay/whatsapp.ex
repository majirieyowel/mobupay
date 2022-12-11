defmodule Mobupay.Whatsapp do
  @moduledoc """
  The Whatsapp context.
  """

  import Ecto.Query, warn: false
  alias Mobupay.Repo

  alias Mobupay.Whatsapp.State

  def create(state_params) do
    %State{}
    |> State.changeset(state_params)
    |> Repo.insert()
  end

  def get_by_msisdn(msisdn) do
    State
    |> where([state], state.msisdn == ^msisdn)
    |> Repo.one()
  end

  def get_by_email(email) do
    State
    |> where([state], state.email == ^email)
    |> Repo.one()
  end

  def get_state_by_confirmation_token(token) do
    State
    |> where([state], state.email_confirmation_token == ^token)
    |> Repo.one()
  end

  def update(state, attrs) do
    state
    |> State.changeset(attrs)
    |> Repo.update()
  end
end
