defmodule EVerApi.Ever.Talk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "talks" do
    field :title, :string
    field :details, :string
    field :summary, :string
    field :start_time, :utc_datetime
    field :duration, :integer
    field :tags, {:array, :string}
    field :allow_comments, :boolean, default: false

    embeds_one :video, EVerApi.Ever.Video

    belongs_to :event, EVerApi.Ever.Event
    many_to_many :speakers, EVerApi.Ever.Speaker, join_through: EVerApi.Ever.SpeakerTalk, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(talk, attrs) do
    talk
    |> cast(attrs, [:name, :body, :start_time, :duration, :video_url, :tags, :allow_comments, :event_id])
    |> validate_required([:title, :event_id])
    |> foreign_key_constraint(:event_id)
  end
end
