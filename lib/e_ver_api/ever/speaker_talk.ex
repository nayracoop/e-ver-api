defmodule EVerApi.Ever.SpeakerTalk do
  use Ecto.Schema

  @primary_key false

  schema "speakers_talks" do
    belongs_to :speaker, EVerApi.Ever.Speaker
    belongs_to :talk, EVerApi.Ever.Talk
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> Ecto.Changeset.cast(params, [:speaker_id, :talk_id])
      |> Ecto.Changeset.validate_required([:speaker_id, :talk_id])
  end
end
