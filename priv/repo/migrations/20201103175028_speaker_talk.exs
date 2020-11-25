defmodule EVerApi.Repo.Migrations.SpeakerTalk do
  use Ecto.Migration

  def change do
    create table(:speakers_talks) do
      add :speaker_id, references(:speakers, on_delete: :delete_all), primary_key: true
      add :talk_id, references(:talks, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create(index(:speakers_talks, [:speaker_id]))
    create(index(:speakers_talks, [:talk_id]))
  end
end
