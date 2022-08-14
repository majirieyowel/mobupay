defmodule Mobupay.AccountTest do
  use Mobupay.DataCase

  alias Mobupay.Account

  describe "users" do
    alias Mobupay.Account.User

    import Mobupay.AccountFixtures

    @invalid_attrs %{country_code: nil, msisdn: nil, reference: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Account.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Account.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{country_code: "some country_code", msisdn: "some msisdn", reference: "some reference"}

      assert {:ok, %User{} = user} = Account.create_user(valid_attrs)
      assert user.country_code == "some country_code"
      assert user.msisdn == "some msisdn"
      assert user.reference == "some reference"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{country_code: "some updated country_code", msisdn: "some updated msisdn", reference: "some updated reference"}

      assert {:ok, %User{} = user} = Account.update_user(user, update_attrs)
      assert user.country_code == "some updated country_code"
      assert user.msisdn == "some updated msisdn"
      assert user.reference == "some updated reference"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
      assert user == Account.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Account.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Account.change_user(user)
    end
  end
end
