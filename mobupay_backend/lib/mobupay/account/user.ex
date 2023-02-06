defmodule Mobupay.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mobupay.Account.{BankAccount, Card, Withdrawal}

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  @derive {Jason.Encoder,
           only: [
             :msisdn,
             :email,
             :country,
             :currency,
             :ref,
             :bank_accounts,
             :account_balance,
             :book_balance,
             :cards,
             :balance
           ]}

  schema "users" do
    field :email, :string

    field :email_confirmation_token, :string
    field :email_confirmed_at, :utc_datetime

    field :msisdn, :string
    field :country, :string
    field :currency, :string
    field :ref, :string
    field :city, :string
    field :region, :string
    field :account_balance, :integer, default: 0
    field :book_balance, :integer, default: 0
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :balance, :string, virtual: true

    field :state, :string
    field :state_action, :string
    field :state_param, :map
    field :state_action_expiration, :utc_datetime
    field :language, :string
    field :has_onboarded, :boolean, default: false

    has_many(:bank_accounts, BankAccount)
    has_many(:cards, Card)
    has_many(:withdrawals, Withdrawal)

    timestamps()
  end

    def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :email_confirmation_token,
      :msisdn,
      :ref,
      :has_onboarded,
      :state,
      :state_action,
      :language,
      :state_param,
      :state_action_expiration
    ])
    |> validate_required([:msisdn, :state])
  end

  @doc false
  # def partial_onboarding_changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:msisdn, :country, :city, :region])
  #   |> validate_required_onboarding()
  #   |> validate_msisdn()
  # end

  # def full_onboarding_changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:msisdn, :country, :currency, :city, :region, :ref, :password])
  #   |> validate_required([:msisdn, :country, :ref, :password])
  #   |> validate_password
  #   |> encrypt_and_put_password()
  #   |> validate_msisdn()
  # end

  def save_email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> update_change(:email, &String.downcase(&1))
  end

  def update_balance_changeset(user, attrs) do
    user
    |> cast(attrs, [:account_balance, :book_balance])
    |> validate_required([:account_balance, :book_balance])
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required(:email, message: "Email is required!")
    |> validate_format(:email, @mail_regex, message: "Invalid email format")
  end

  defp validate_required_onboarding(changeset) do
    changeset
    |> validate_required(:msisdn, message: "Phone number is required!")
    |> validate_required(:country, message: "Country code is required!")
  end

  defp encrypt_and_put_password(changeset) do
    password = get_change(changeset, :password)

    if changeset.valid? && password do
      changeset
      |> validate_length(:password, max: 30, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp validate_msisdn(changeset) do
    changeset
    |> validate_format(:msisdn, ~r/^[0-9]*$/, message: "Only numbers without space allowed")
    |> unsafe_validate_unique(:msisdn, Mobupay.Repo, message: "Mobile number registered. Sign in.")
    |> unique_constraint(:msisdn, message: "Mobile number registered. Sign in.")
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 8, max: 60)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[0-9]/, message: "at least one digit")

    # |> validate_format(:password, ~r/[!"#$%&'()*+,-.\/:;<=>?@[\]^_`{|}~]/,
    #   message: "at least one special character"
    # )
  end
end
