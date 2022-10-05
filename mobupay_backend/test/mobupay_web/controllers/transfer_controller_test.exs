defmodule MobupayWeb.TransferControllerTest do
  use MobupayWeb.ConnCase

  import Mobupay.Test.Factory
  import Mox

  alias Mobupay.Transactions
  alias Mobupay.Account
  alias Mobupay.Clients.TwilioServiceMock
  alias Mobupay.Clients.PaystackServiceMock

  @password "@Nelie&e12"

  setup %{conn: conn} do
    user = insert(:user)

    token_conn =
      post(conn, Routes.v1_session_path(conn, :login), msisdn: user.msisdn, password: @password)

    %{"access_token" => access_token} = json_response(token_conn, 200)["data"]

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     access_token: access_token,
     current_user: user}
  end

  describe "index" do
    test "will successfully initiate a 'Default' transaction", %{
      conn: conn,
      access_token: access_token,
      current_user: %{email: email, msisdn: msisdn}
    } do
      input_amount = "50"
      expected_amount = 5000
      to_msisdn = "2348108125270"

      TwilioServiceMock
      |> expect(:lookup, fn _msisdn ->
        {:ok, %{"country_code" => "NG", "phone_number" => msisdn}}
      end)

      paystack_pk = Faker.String.base64(20)

      System.put_env("PAYSTACK_PUBLIC_KEY", paystack_pk)

      payload = %{
        narration: "Transfer from userA to userB",
        to_msisdn: to_msisdn,
        amount: input_amount,
        ip_address: "127.0.0.1",
        device: Faker.Internet.UserAgent.mobile_user_agent(),
        funding_channel: "Default",
        card: ""
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(Routes.v1_transfer_path(conn, :index), payload)

      assert %{
               "status" => true,
               "data" => %{
                 "amount" => ^expected_amount,
                 "channels" => ["card"],
                 "paystack_pk" => ^paystack_pk,
                 "email" => ^email,
                 "funding_channel" => "Default",
                 "ref" => ref
               }
             } = json_response(conn, 200)

      %Transactions.Transaction{
        is_visible: visibility,
        status: status,
        amount: amount,
        from_msisdn: from_msisdn,
        to_msisdn: transformed_to_msisdn
      } = Transactions.get_by_ref(ref)

      assert visibility == false
      assert status == :initiated
      assert amount == expected_amount
      assert from_msisdn == msisdn
      assert transformed_to_msisdn == "wait_" <> to_msisdn
    end
  end

  describe "verify" do
    test "will successfully verify card transaction", %{
      conn: conn,
      access_token: access_token,
      current_user: _current_user
    } do
      PaystackServiceMock
      |> expect(:verify_transaction, fn _ref ->
        {:ok,
         %{
           "status" => true,
           "data" => %{
             "status" => "success",
             "currency" => "NGN",
             "channel" => "card",
             "authorization" => %{
               "account_name" => nil,
               "authorization_code" => "AUTH_4b9votriqu",
               "bank" => "TEST BANK",
               "bin" => "408408",
               "brand" => "visa",
               "card_type" => "visa ",
               "channel" => "card",
               "country_code" => "NG",
               "exp_month" => "12",
               "exp_year" => "2030",
               "last4" => "4081"
             }
           }
         }}
      end)

      ref = Faker.String.base64(10)
      request_to_msisdn = "234" <> Nanoid.generate(10, "01233456789")

      %Transactions.Transaction{amount: transaction_amount} =
        insert(:transaction, ref: ref, to_msisdn: "wait_" <> request_to_msisdn)

      payload = %{
        ref: ref
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(Routes.v1_transfer_path(conn, :verify), payload)

      assert %{
               "data" => %{
                 "card" => %{
                   "ref" => _,
                   "bank" => "TEST BANK",
                   "card_type" => "visa",
                   "country_code" => "NG",
                   "exp_month" => "12",
                   "exp_year" => "2030",
                   "last4" => "4081",
                   "bin" => "408408"
                 },
                 "to_msisdn" => ^request_to_msisdn,
                 "transaction_amount" => ^transaction_amount,
                 "transaction_currency" => "NGN"
               },
               "status" => true
             } = json_response(conn, 200)

      %Transactions.Transaction{
        is_visible: visibility,
        status: status,
        to_msisdn: tranx_to_msisdn
      } = Transactions.get_by_ref(ref)

      assert visibility == true
      assert status == :floating
      assert tranx_to_msisdn == request_to_msisdn
    end

    test "same card will not be added twice" do
      user = insert(:user)

      authorization = %{
        "account_name" => nil,
        "authorization_code" => "AUTH_4b9votriqu",
        "bank" => "TEST BANK",
        "bin" => "408408",
        "brand" => "visa",
        "card_type" => "visa ",
        "channel" => "card",
        "country_code" => "NG",
        "exp_month" => "12",
        "exp_year" => "2030",
        "last4" => "4081"
      }

      for _n <- 1..5, do: Account.create_card(user, authorization)

      assert length(Account.list_cards(user)) === 1
    end
  end

  describe "accept" do
    test "can successfully accept money", %{
      conn: conn,
      access_token: access_token,
      current_user: %{msisdn: msisdn}
    } do
      ref = Faker.String.base64(10)

      %Transactions.Transaction{amount: amount, id: transaction_id} =
        insert(:transaction, ref: ref, status: :floating, to_msisdn: msisdn)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(Routes.v1_transfer_path(conn, :accept, ref))

      assert %{
               "data" => %{
                 "new_balance" => ^amount,
                 "transaction" => %{
                   "amount" => ^amount,
                   "from_msisdn" => _,
                   "from_ref" => _,
                   "inserted_at" => _,
                   "narration" => _,
                   "ref" => ^ref,
                   "status" => "accepted",
                   "to_msisdn" => ^msisdn,
                   "to_ref" => _
                 }
               },
               "status" => true
             } = json_response(conn, 200)

      assert %{
               msisdn: ^msisdn,
               amount: ^amount
             } = Transactions.get_transaction_ledger(transaction_id)
    end
  end

  describe "reject" do
    test "can successfully reject money", %{
      conn: conn,
      access_token: access_token,
      current_user: %{msisdn: msisdn}
    } do
      ref = Faker.String.base64(10)

      %Transactions.Transaction{amount: amount, from_msisdn: from_msisdn, id: transaction_id} =
        insert(:transaction, ref: ref, status: :floating, to_msisdn: msisdn)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(Routes.v1_transfer_path(conn, :reject, ref))

      assert %{"data" => %{}, "status" => true} = json_response(conn, 200)

      assert %{
               msisdn: ^from_msisdn,
               amount: ^amount
             } = Transactions.get_transaction_ledger(transaction_id)
    end
  end

  describe "reclaim" do
    test "can successfully reclaim money", %{
      conn: conn,
      access_token: access_token,
      current_user: %{msisdn: msisdn}
    } do
      ref = Faker.String.base64(10)

      %Transactions.Transaction{amount: amount, from_msisdn: from_msisdn, id: transaction_id} =
        insert(:transaction, ref: ref, status: :floating, from_msisdn: msisdn)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(Routes.v1_transfer_path(conn, :reclaim, ref))

      assert %{
               "data" => %{
                 "new_balance" => ^amount,
                 "transaction" => %{
                   "amount" => ^amount,
                   "from_msisdn" => ^msisdn,
                   "from_ref" => _,
                   "inserted_at" => _,
                   "narration" => _,
                   "ref" => ^ref,
                   "status" => "reclaimed",
                   "to_msisdn" => _,
                   "to_ref" => _
                 }
               },
               "status" => true
             } = json_response(conn, 200)

      assert %{
               msisdn: ^from_msisdn,
               amount: ^amount
             } = Transactions.get_transaction_ledger(transaction_id)
    end
  end
end
