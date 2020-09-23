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

      add :talk_id, references(:talks, on_delete: :nothing)

      timestamps()
    end

  end
end
