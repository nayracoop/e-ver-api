defmodule EVerApi.Repo.Migrations.CreateTalks do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    create table(:talks) do
      add :title, :string
      add :details, :string
      add :summary, :string
      add :start_time, :utc_datetime
      add :duration, :integer
      add :video, :map
      add :tags, {:array, :string}
      add :allow_comments, :boolean, default: false

      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
      soft_delete_columns()
    end
  end
end
