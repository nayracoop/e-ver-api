defmodule EVerApi.Ever.Speaker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "speakers" do
    field :name, :string
    field :first_name, :string
    field :last_name, :string
    field :company, :string
    field :role, :string
    field :bio, :string
    field :avatar, :string

    many_to_many :talks, EVerApi.Ever.Talk, join_through: EVerApi.Ever.SpeakerTalk, on_replace: :delete
    belongs_to :event, EVerApi.Ever.Event

    timestamps()
  end

  @doc false
  def changeset(speaker, attrs) do
    speaker
    |> cast(attrs, [:name, :first_name, :last_name, :role, :company, :bio, :avatar])
    |> validate_required([:name, :event_id])
    |> foreign_key_constraint(:event_id)
  end
end
