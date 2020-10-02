defmodule EVerApiWeb.UserControllerTest do
  use EVerApiWeb.ConnCase, async: true

  alias EVerApi.Accounts
  alias EVerApi.Accounts.User

  @moduletag :user_controller_case

  @create_attrs %{
    email: "test.queen@nayra.coop",
    password: "123456",
    password_confirmation: "123456",
    first_name: "mrs test",
    last_name: "queen",
    username: "test_queen",
    organization: "nayracoop"
  }
  @update_attrs %{
    name: "some updated name",
    password: "some updated password"
  }
  @invalid_attrs %{name: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  defp assert_401(conn, f, route) do
    conn =
      conn
      |> delete_req_header("authorization")
      |> f.(route)
    assert json_response(conn, 401)["message"] == "unauthenticated"
  end

  setup %{conn: conn} do
    insert(:user)
    jwt = EVerApi.Accounts.token_sign_in("nayra@fake.coop", "123456")
    {:ok, jwt_string, _} = jwt
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt_string}")

    # IO.inspect(conn)
    {:ok, conn: conn}
  end

  describe "index" do

    @tag individual_test: "users_index_401"
    test "401 for list users", %{conn: conn} do
      assert_401(conn, &get/2, Routes.user_path(conn, :index))
    end

    @tag individual_test: "users_index_list"
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      response = json_response(conn, 200)["data"]
      expected = %{
        "email" => "nayra@fake.coop",
        "events" => [],
        "first_name" => "señora",
        "last_name" => "nayra",
        "organization" => "Coop. de trabajo Nayra ltda",
        "username" => "nayra"
      }

      assert expected = response
      [%{"id" => id}] = response
      assert is_number(id)
    end
  end

  describe "create user" do
    @tag individual_test: "users_index_401"
    test "401 for create users", %{conn: conn} do
      assert_401(conn, &post/2, Routes.user_path(conn, :create))
    end

    @tag individual_test: "users_create"
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
                "id" => id,
                "email" => "test.queen@nayra.coop",
                "first_name" => "mrs test",
                "last_name" => "queen",
                "username" => "test_queen",
                "organization" => "nayracoop",
                "events" => []
              } = json_response(conn, 200)["data"]
      # should not contain the password_hash field
      refute  Kernel.match?(%{"password_hash" => pass}, json_response(conn, 200)["data"])
    end

    @tag individual_test: "users_create_invalid"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "401 for update users", %{conn: conn} do
      assert_401(conn, &put/2, Routes.user_path(conn, :update))
    end

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "password" => "some updated password"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "401 for delete users", %{conn: conn} do
      assert_401(conn, &delete/2, Routes.user_path(conn, :delete))
    end

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
