defmodule EVerApi.Repo.Migrations.SpeakerTalk do
  use Ecto.Migration

  def change do
    create table(:speakers_talks) do
      add :speaker_id, references(:speakers)
      add :talk_id, references(:talks)

      timestamps()
    end
  end
end
