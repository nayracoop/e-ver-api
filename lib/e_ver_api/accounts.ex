defmodule EVerApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias EVerApi.Repo

  alias EVerApi.Accounts.User
  alias Guardian.Permissions
  alias EVerApi.Guardian
  import Bcrypt
  import Ecto.SoftDelete.Query

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    query = from(u in User, select: u)
      |> with_undeleted()
    Repo.all(query) |> Repo.preload(:events)
  end

  @doc """
  Gets a single user.

  Does not Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id) do
    query = from(u in User, select: u)
      |> with_undeleted()
    Repo.get(query, id) |> Repo.preload(:events)
  end
    @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    query = from(u in User, select: u)
      |> with_undeleted()
    Repo.get!(query, id) |> Repo.preload(:events)
  end

  @doc """
  Gets a single user by email.

  Does not Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by(:email, "nayre@nayro.coop")
      %User{}

      iex> get_user_by(:email, "nayre@nayro.coop")
      nil

  """
  def get_user_by(:email, email) when is_binary(email)  do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.soft_delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user, %{}, permissions: user.permissions)
      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
    do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email)  do
    case Repo.get_by(User, email: email) do
      nil ->
        # if user does not exists executes a dummy check
        Bcrypt.no_user_verify
        {:error, "Login error"}
      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    # uses the virtual for check
    if Bcrypt.check_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

end
