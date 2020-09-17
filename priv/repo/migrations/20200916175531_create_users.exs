defmodule EVerApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :organization, :string
      add :password, :string

      timestamps()
    end

  end
end
