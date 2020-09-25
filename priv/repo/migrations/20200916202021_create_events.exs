defmodule EVerApi.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :string
      add :summary, :string
      add :url, :string
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime

      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

  end
end
