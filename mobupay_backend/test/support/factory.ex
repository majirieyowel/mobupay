defmodule Mobupay.Test.Factory do
  @moduledoc nil

  use ExMachina.Ecto, repo: Mobupay.Repo

  alias Mobupay.Account.{User}
  alias Mobupay.Transactions.Transaction

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      msisdn: sequence(:msisdn, ["234", "233", "245"]) <> Nanoid.generate(10, "01233456789"),
      country: sequence(:country, ["Nigeria", "Ghana"]),
      city: sequence(:city, ["Lagos", "Abuja", "Ghana"]),
      region: sequence(:region, ["Lagos", "Abuja", "Ghana"]),
      ref: sequence("ref"),
      hashed_password: "$2b$12$ToLdPz6VDERXsdBIGOfSJ.KXAgI5pSKdGtzrqNva6.kNYjlFzv5uy"
    }
  end

  def transaction_factory do
    %Transaction{
      ref: sequence("ref"),
      to_ref: sequence("to_ref"),
      from_ref: sequence("from_ref"),
      amount: 10_000,
      status: :floating,
      from_msisdn: "234" <> Nanoid.generate(10, "01233456789"),
      to_msisdn: "234" <> Nanoid.generate(10, "04232456789"),
      narration: "Funds transfer to moses",
      ip_address: "127.0.0.1",
      device: Faker.Internet.UserAgent.mobile_user_agent(),
      is_visible: true
    }
  end
end
