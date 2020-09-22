defmodule EVerApi.Repo.Migrations.CreateTalks do
  use Ecto.Migration

  def change do
    create table(:talks) do
      add :name, :string
      add :body, :string
      add :start_time, :utc_datetime
      add :duration, :integer
      add :video_url, :string
      add :tags, {:array, :string}

      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

  end
end
