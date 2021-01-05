defmodule EVerApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string, unique: true
      add :username, :string, unique: true
      add :organization, :string
      add :password_hash, :string

      #roles
      add :permissions, :map, default: %{ default: [:read]}


      timestamps()
      soft_delete_columns()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
