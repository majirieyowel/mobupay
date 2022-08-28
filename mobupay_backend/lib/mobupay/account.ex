defmodule Mobupay.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Mobupay.Repo

  alias Mobupay.Account.{User, BankAccount, Contact, Card, Withdrawal}
  alias Mobupay.Helpers.Token

  @spec partial_onboard(%{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          Ecto.Changeset.t()
  def partial_onboard(%{"msisdn" => _msisdn} = user_params) do
    %User{}
    |> User.partial_onboarding_changeset(user_params)
  end

  def full_onboard(user_params) do
    %User{}
    |> User.full_onboarding_changeset(user_params)
    |> Repo.insert()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_by_msisdn(msisdn) do
    User
    |> where([user], user.msisdn == ^msisdn)
    |> Repo.one()
  end

  def save_email(user, attrs) do
    user
    |> User.save_email_changeset(attrs)
    |> Repo.update()
  end

  # Bank Account

  def create_bank_account(%User{id: user_id} = user, params) do
    params =
      Map.put(params, "ref", Token.generate(:random))
      |> Map.put("user_id", user_id)

    changeset =
      user
      |> Ecto.build_assoc(:bank_accounts)
      |> BankAccount.changeset(params)

    Repo.insert(changeset)
  end

  def list_bank_accounts(user_id) do
    BankAccount
    |> where([ba], ba.user_id == ^user_id)
    |> Repo.all()
  end

  def list_bank_account_by_ref(ref) do
    BankAccount
    |> where([ba], ba.ref == ^ref)
    |> Repo.one()
  end

  def list_user_bank_account_by_ref(%User{id: user_id}, ref) do
    BankAccount
    |> where([ba], ba.ref == ^ref)
    |> where([ba], ba.user_id == ^user_id)
    |> Repo.one()
  end

  def nuban_exists?(user_id, nuban) do
    BankAccount
    |> where([ba], ba.nuban == ^nuban)
    |> where([ba], ba.user_id == ^user_id)
    |> Repo.exists?()
  end

  def msisdn_exists?(msisdn) do
    User
    |> where([u], u.msisdn == ^msisdn)
    |> Repo.exists?()
  end

  def delete_bank_account(%BankAccount{} = bank_account) do
    Repo.delete(bank_account)
  end

  # Contacts

  def list_contacts(user_id, params) do
    Contact
    |> where([co], co.user_id == ^user_id)
    |> Repo.paginate(params)
  end

  def create_contact(user, bank_account_params) do
    changeset =
      user
      |> Ecto.build_assoc(:contacts)
      |> Contact.changeset(bank_account_params)

    Repo.insert(changeset)
  end

  def msisdn_exists?(user_id, msisdn) do
    Contact
    |> where([co], co.msisdn == ^msisdn)
    |> where([co], co.user_id == ^user_id)
    |> Repo.exists?()
  end

  def contact_name_exists?(user_id, name) do
    Contact
    |> where([co], co.name == ^name)
    |> where([co], co.user_id == ^user_id)
    |> Repo.exists?()
  end

  def search_contacts(query, user_id) do
    param = "%#{query}%"

    from(c in Contact, where: ilike(c.name, ^param), where: c.user_id == ^user_id)
    |> order_by([contact], desc: contact.id)
    |> Repo.all()
  end

  # card

  def create_card(%User{id: user_id} = user, %{
        "authorization_code" => authorization_code,
        "bank" => bank,
        "card_type" => card_type,
        "country_code" => country_code,
        "exp_month" => exp_month,
        "exp_year" => exp_year,
        "last4" => last4,
        "bin" => bin
      }) do
    case card_exists?(user_id, last4, card_type) do
      false ->
        changeset =
          user
          |> Ecto.build_assoc(:cards)
          |> Card.changeset(%{
            ref: Token.generate(:random),
            authorization_code: authorization_code,
            bank: bank,
            card_type: String.trim(card_type),
            country_code: country_code,
            exp_month: exp_month,
            exp_year: exp_year,
            last4: String.trim(last4),
            bin: bin
          })

        Repo.insert(changeset)

      true ->
        {:ok, %{}}
    end
  end

  def get_user_card_by_ref(%User{id: user_id}, ref) do
    Card
    |> where([c], c.user_id == ^user_id)
    |> where([c], c.ref == ^ref)
    |> Repo.one()
  end

  def card_exists?(user_id, last4, card_type) do
    Card
    |> where([c], c.user_id == ^user_id)
    |> where([c], c.last4 == ^String.trim(last4))
    |> where([c], c.card_type == ^String.trim(card_type))
    |> Repo.exists?()
  end

  def get_card_by_ref(ref) do
    Card
    |> where([c], c.ref == ^ref)
    |> Repo.one()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  # Withdrawal

  def list_user_withdrawals(%User{id: user_id}, params \\ %{}) do
    Withdrawal
    |> where([t], t.user_id == ^user_id)
    |> order_by([t], desc: t.id)
    |> Repo.paginate(params)
  end

  def create_withdrawal(user, attrs) do
    user
    |> Ecto.build_assoc(:withdrawals)
    |> Withdrawal.changeset(attrs)
    |> Repo.insert()
  end

    def get_withdrawal_by_ref(ref) do
    Withdrawal
    |> where([w], w.ref == ^ref)
    |> Repo.one()
  end
end
