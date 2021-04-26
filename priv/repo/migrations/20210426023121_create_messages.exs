defmodule EVerApi.Repo.Migrations.CreateMessages do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    create table(:messages) do
      add :body, :text

      add :talk_id, references(:talks, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
      soft_delete_columns()
    end

    create index(:messages, [:talk_id])
    create index(:messages, [:user_id])
  end
end
