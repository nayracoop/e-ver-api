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
    username: "nayrista",
    first_name: "test",
    last_name: "queer"
  }
  @invalid_attrs %{first_name: nil, last_name: nil}

  describe "with logged-in user" do
    setup %{conn: conn, login_as: email} do
      user = insert(:user, email: email)

      {:ok, jwt_string, _} = EVerApi.Accounts.token_sign_in(email, "123456")

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt_string}")

      # |> bypass_through(EVerApiWeb.Router)
      {:ok, conn: conn, user: user}
    end

    @tag individual_test: "users_index_list", login_as: "email@email.com"
    test "lists all users", %{
      conn: conn,
      user: %User{
        email: email,
        first_name: first_name,
        last_name: last_name,
        organization: organization,
        username: username
      }
    } do
      conn = get(conn, Routes.user_path(conn, :index))

      assert response = json_response(conn, 200)["data"]

      assert [
               %{
                 "email" => ^email,
                 "events" => [],
                 "first_name" => ^first_name,
                 "last_name" => ^last_name,
                 "organization" => ^organization,
                 "username" => ^username
               }
             ] = response

      [%{"id" => id}] = response
      assert is_number(id)
    end

    @tag individual_test: "users_show", login_as: "email@email.com"
    test "get an user by id", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert user = json_response(conn, 200)["data"]
    end

    @tag individual_test: "users_show", login_as: "email@email.com"
    test "404 for get an user by id", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, -1))
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    @tag individual_test: "users_create", login_as: "email@email.com"
    test "renders created user when data is valid", %{conn: conn} do
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
      refute Kernel.match?(%{"password_hash" => _pass}, json_response(conn, 200)["data"])
    end

    @tag individual_test: "users_create", login_as: "email@email.com"
    test "renders creation errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "users_update", login_as: "email@email.com"
    test "renders updated user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "first_name" => "test",
               "last_name" => "queer",
               "username" => "nayrista"
             } = json_response(conn, 200)["data"]
    end

    @tag individual_test: "users_update", login_as: "email@email.com"
    test "renders update errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "users_update", login_as: "email@email.com"
    test "renders errors when an unique field is updated with existent data", %{
      conn: conn,
      user: %User{username: username}
    } do
      {:ok, user2} = Accounts.create_user(Map.replace!(@create_attrs, :username, "dhavide.lebon"))
      # try to change current username with an already existent username in database
      conn = put(conn, Routes.user_path(conn, :update, user2), user: %{username: username})

      assert json_response(conn, 422)["errors"] != %{}
      assert %{"username" => ["has already been taken"]} = json_response(conn, 422)["errors"]
    end

    @tag individual_test: "users_delete", login_as: "email@email.com"
    test "404 for delete users", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, -1))
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    @tag individual_test: "users_delete", login_as: "email@email.com"
    test "deletes chosen user", %{conn: conn} do
      user_to_delete = insert(:user)
      conn = delete(conn, Routes.user_path(conn, :delete, user_to_delete))
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, user_to_delete))
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.user_path(conn, :index)),
        get(conn, Routes.user_path(conn, :show, 1)),
        post(conn, Routes.user_path(conn, :create, %{})),
        put(conn, Routes.user_path(conn, :update, "123")),
        delete(conn, Routes.user_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert json_response(conn, 401)["message"] == "unauthenticated"
      end
    )
  end
end
