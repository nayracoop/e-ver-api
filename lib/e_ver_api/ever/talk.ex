defmodule EVerApi.Ever.Talk do
  use Ecto.Schema
  import Ecto.SoftDelete.Schema
  import Ecto.Changeset

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
  end

  defp video_changeset(video, attrs) do
    video
    |> cast(attrs, [:uri, :type, :autoplay])
  end
end
