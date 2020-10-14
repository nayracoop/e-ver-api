defmodule EVerApi.Accounts.User do
  use Ecto.Schema
  import Ecto.SoftDelete.Schema
  import Ecto.Changeset
  import Bcrypt, only: [hash_pwd_salt: 1]

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :organization, :string
    field :username, :string, unique: true
    field :email, :string, unique: true
    field :password_hash, :string
    # virtual fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    soft_delete_schema()

    has_many :events, EVerApi.Ever.Event

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :username, :organization, :password, :password_confirmation])
    |> validate_required([:first_name, :last_name, :email, :username, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/) # this is very basic hahaha
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> unique_constraint([:email])
    |> unique_constraint([:username])
    |> put_password_hash
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :username, :organization])
    |> validate_required([:first_name, :last_name, :email, :username])
    |> validate_format(:email, ~r/@/) # this is very basic hahaha
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> unique_constraint([:email])
    |> unique_constraint([:username])
    |> put_password_hash
  end

  def put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, hash_pwd_salt(pass))
      _ ->
        changeset
    end
  end


end
