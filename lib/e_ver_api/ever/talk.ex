defmodule EVerApi.Ever.Talk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "talks" do
    field :body, :string
    field :duration, :integer
    field :name, :string
    field :start_time, :utc_datetime
    field :tags, {:array, :string}
    field :video_url, :string

    belongs_to :event, EVerApi.Ever.Event

    timestamps()
  end

  @doc false
  def changeset(talk, attrs) do
    talk
    |> cast(attrs, [:name, :body, :start_time, :duration, :video_url, :tags, :event_id])
    |> validate_required([:name, :body, :start_time, :duration, :video_url, :event_id])
    |> foreign_key_constraint(:event_id)
  end
end
