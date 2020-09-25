defmodule EVerApi.Repo.Migrations.CreateSponsors do
  use Ecto.Migration

  def change do
    create table(:sponsors) do
      add :name, :string
      add :logo, :string
      add :website, :string

      add :event_id, references(:events, on_delete: :nothing)
      timestamps()
    end

  end
end
