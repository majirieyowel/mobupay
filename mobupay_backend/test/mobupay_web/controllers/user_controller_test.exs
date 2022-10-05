defmodule MobupayWeb.UserControllerTest do
  use MobupayWeb.ConnCase

  import Mobupay.AccountFixtures

  alias Mobupay.Account.User

  @create_attrs %{
    country_code: "some country_code",
    msisdn: "some msisdn",
    reference: "some reference"
  }
  @update_attrs %{
    country_code: "some updated country_code",
    msisdn: "some updated msisdn",
    reference: "some updated reference"
  }
  @invalid_attrs %{country_code: nil, msisdn: nil, reference: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      payload = %{
        country_code: "some country_code",
        msisdn: "some msisdn",
        reference: "some reference"
      }

      conn = post(conn, Routes.user_path(conn, :create), payload)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "country_code" => "some country_code",
               "msisdn" => "some msisdn",
               "reference" => "some reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "country_code" => "some updated country_code",
               "msisdn" => "some updated msisdn",
               "reference" => "some updated reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
