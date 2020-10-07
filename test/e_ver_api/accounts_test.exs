defmodule EVerApi.AccountsTest do
  use EVerApi.DataCase

  alias EVerApi.Accounts
  import Bcrypt

  @password "123456"

  @moduletag :accounts
  describe "users" do
    alias EVerApi.Accounts.User

    @valid_attrs %{
      email: "test.kinga@nayra.coop",
      password: "123456",
      password_confirmation: "123456",
      first_name: "mrs test",
      last_name: "kinga",
      username: "test_kinga",
      organization: "nayracoop"
    }

    defp valid_fetch() do
      %{
        email: "test.kinga@nayra.coop",
        first_name: "mrs test",
        last_name: "kinga",
        username: "test_kinga",
        organization: "nayracoop"
      }
    end

    @update_attrs %{first_name: "The Royal", last_name: "queen"}
    @invalid_attrs %{name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    @tag individual_test: "list_users"
    test "list_users/0 returns all users" do
      user = user_fixture()
      [listed_user] = Accounts.list_users()
      assert %{
        email: "test.kinga@nayra.coop",
        first_name: "mrs test",
        last_name: "kinga",
        username: "test_kinga",
        organization: "nayracoop",
        password_hash: hash
      } = listed_user
      # check hashed pass
      assert {:ok, _} = Bcrypt.check_pass(listed_user, @password)
    end

    @tag individual_test: "list_users_empty"
    test "list_users/0 returns empty list if theres no users" do
      #user = user_fixture()
      assert [] == Accounts.list_users()
    end

    @tag individual_test: "get_user"
    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert %{
        email: "test.kinga@nayra.coop",
        first_name: "mrs test",
        last_name: "kinga",
        username: "test_kinga",
        organization: "nayracoop"
      } = Accounts.get_user(user.id)
      assert Accounts.get_user(-1) == nil
    end

    @tag individual_test: "get_user"
    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert %{
        email: "test.kinga@nayra.coop",
        first_name: "mrs test",
        last_name: "kinga",
        username: "test_kinga",
        organization: "nayracoop"
      } = Accounts.get_user!(user.id)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(-1) end
    end

    @tag individual_test: "create_user"
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert %{
        email: "test.kinga@nayra.coop",
        first_name: "mrs test",
        last_name: "kinga",
        username: "test_kinga",
        organization: "nayracoop"
      } = user
      # check hashed pass
      assert {:ok, _} = Bcrypt.check_pass(user, @password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.name == "some updated name"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
