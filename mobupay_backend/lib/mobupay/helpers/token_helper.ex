defmodule Mobupay.Helpers.Token do
  import Ecto.Query, warn: false

  alias Mobupay.{Account, Repo}

  @number_range "1234567890"

  @alnum_range "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  @otp_length 4

  @random_length 30

  @user_ref_length 10

  def generate(:otp), do: Nanoid.generate(@otp_length, @number_range)

  def generate(:random), do: Nanoid.generate(@random_length, @alnum_range)

  def generate(length), do: Nanoid.generate(length, @alnum_range)

  def generate_unique(:user_ref) do
    generated_otp = Nanoid.generate(@user_ref_length, @alnum_range)

    query = from(u in Account.User, where: u.ref == ^generated_otp)

    case Repo.exists?(query) do
      false ->
        generated_otp
        |> String.downcase()

      true ->
        generate_unique(:user_ref)
    end
  end
end
