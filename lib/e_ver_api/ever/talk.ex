defmodule EVerApi.Ever.Talk do
  use Ecto.Schema
  import Ecto.SoftDelete.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Ecto.SoftDelete.Query

  schema "talks" do
    field :title, :string
    field :details, :string
    field :summary, :string
    field :start_time, :utc_datetime
    field :duration, :integer
    field :tags, {:array, :string}
    field :allow_comments, :boolean, default: false
    soft_delete_schema()

    embeds_one :video, EVerApi.Ever.Video, on_replace: :delete

    belongs_to :event, EVerApi.Ever.Event
    many_to_many :speakers, EVerApi.Ever.Speaker, join_through: EVerApi.Ever.SpeakerTalk, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(talk, attrs) do
    talk
    |> cast(attrs, [:title, :details, :summary, :start_time, :duration, :tags, :allow_comments, :event_id])
    |> cast_embed(:video, with: &video_changeset/2)
    |> validate_required([:title, :event_id])
    |> foreign_key_constraint(:event_id)
    |> changeset_update_speakers(attrs)
  end

  defp video_changeset(video, attrs) do
    video
    |> cast(attrs, [:uri, :type, :autoplay])
  end

  # SPEAKERS association
  defp changeset_update_speakers(talk, %{"speakers" => speaker_ids}) do

    case valid_speakers_ids(speaker_ids) do
      true -> put_assoc(talk, :speakers, upsert_speakers(talk, speaker_ids))
      _ -> add_error(talk, :speakers, "Speakers array must contain only integers")
    end
  end
  defp changeset_update_speakers(talk, _), do: talk # when no changes then no changes

  defp upsert_speakers(talk, speaker_ids) do
    # use either new talk_id from changes otherwise the data event_id.
    event_id = Map.get(talk.changes, :event_id) || Map.get(talk.data, :event_id)
    # TODO maybe check for errors ?
    EVerApi.Ever.Speaker
    |> where([speaker], speaker.id in ^speaker_ids and speaker.event_id == ^event_id)
    |> with_undeleted()
    |> EVerApi.Repo.all()
  end

  defp valid_speakers_ids(ids) do
    is_list(ids) and Enum.all?(ids, fn s -> is_number(s) end)
  end
end
