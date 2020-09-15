defmodule EVerApi.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :string
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime

      timestamps()
    end

  end
end
