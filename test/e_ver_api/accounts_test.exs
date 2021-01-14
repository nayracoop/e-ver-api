defmodule EVerApi.AccountsTest do
  use EVerApi.DataCase, async: true

  alias EVerApi.Accounts
  alias EVerApi.Repo

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

    @update_attrs %{first_name: "The Royal", last_name: "queen"}
    @invalid_attrs %{first_name: nil, last_name: nil}

    @tag individual_test: "list_users"
    test "list_users/0 returns all users" do
      %User{
        email: email,
        first_name: first_name,
        last_name: last_name,
        username: username,
        organization: organization
      } = insert(:user)

      [listed_user] = Accounts.list_users()

      assert %{
               email: ^email,
               first_name: ^first_name,
               last_name: ^last_name,
               username: ^username,
               organization: ^organization
             } = listed_user

    end

    @tag individual_test: "list_users_empty"
    test "list_users/0 returns empty list if there is no users" do
      # user = insert(:user)
      assert [] == Accounts.list_users()
    end

    @tag individual_test: "get_user"
    test "get_user/1 returns the user with given id" do
      %User{
        id: id,
        email: email,
        first_name: first_name,
        last_name: last_name,
        username: username,
        organization: organization
      } = insert(:user)

      assert %{
               email: ^email,
               first_name: ^first_name,
               last_name: ^last_name,
               username: ^username,
               organization: ^organization
             } = Accounts.get_user(id)

      assert Accounts.get_user(-1) == nil
    end

    @tag individual_test: "get_user"
    test "get_user!/1 returns the user with given id" do
      %User{
        id: id,
        email: email,
        first_name: first_name,
        last_name: last_name,
        username: username,
        organization: organization
      } = insert(:user)

      assert %{
               email: ^email,
               first_name: ^first_name,
               last_name: ^last_name,
               username: ^username,
               organization: ^organization
             } = Accounts.get_user(id)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(-1) end
    end

    @tag individual_test: "create_user"
    test "create_user/1 with valid data creates a user" do
      {:ok,
       %User{
         email: "test.kinga@nayra.coop",
         first_name: "mrs test",
         last_name: "kinga",
         username: "test_kinga",
         organization: "nayracoop"
       } = user} = Accounts.create_user(@valid_attrs)

      # check hashed pass
      assert {:ok, _} = Bcrypt.check_pass(user, @password)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    @tag individual_test: "create_user_unique"
    test "create_user/1 with not unique data returns error changeset" do
      insert(:user, @valid_attrs)

      assert {:error, %Ecto.Changeset{action: :insert, errors: [err]}} =
               Accounts.create_user(@valid_attrs)

      assert {:email, _} = err
      # username must be unique
      assert {:error, %Ecto.Changeset{action: :insert, errors: [err]}} =
               Accounts.create_user(Map.put(@valid_attrs, :email, "changed_email@nayra.coop"))

      assert {:username, _} = err
    end

    # @tag individual_test: "update_user"
    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.first_name == "The Royal"
      assert user.last_name == "queen"
    end

    @tag individual_test: "update_user_invalid"
    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      user_ = Accounts.get_user!(user.id)

      assert %{
               first_name: "mrs test",
               last_name: "kinga"
             } = user_
    end

    @tag individual_test: "update_user"
    test "update_user/2 should not change password" do
      user = insert(:user)

      assert {:ok, %User{} = user} =
               Accounts.update_user(user, %{
                 password: "holaholu",
                 password_confirmation: "holaholu"
               })

      # get fresh updated user without virtuals
      user = Accounts.get_user(user.id)
      assert {:ok, _} = Bcrypt.check_pass(user, @password)
    end

    @tag individual_test: "delete_user"
    test "delete_user/1 deletes the user" do
      user = insert(:user)
      Accounts.delete_user(user)

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert nil == Accounts.get_user(user.id)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
      # verify soft deletion
      del_user = Repo.get(User, user.id)
      assert del_user != nil
      assert del_user.deleted_at != nil
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
