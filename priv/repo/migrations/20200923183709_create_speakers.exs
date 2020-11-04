defmodule EVerApi.Repo.Migrations.CreateSpeakers do
  use Ecto.Migration

  def change do
    create table(:speakers) do
      add :name, :string
      add :first_name, :string
      add :last_name, :string
      add :company, :string
      add :role, :string
      add :bio, :string
      add :avatar, :string

      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

  end
end
