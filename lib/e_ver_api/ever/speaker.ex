defmodule EVerApi.Ever.Speaker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "speakers" do
    field :avatar, :string
    field :bio, :string
    field :company, :string
    field :first_name, :string
    field :last_name, :string
    field :name, :string
    field :role, :string

    many_to_many :talks, EVerApi.Ever.Talk, join_through: EVerApi.Ever.SpeakerTalk
    belongs_to :event, EVerApi.Ever.Event

    timestamps()
  end

  @doc false
  def changeset(speaker, attrs) do
    speaker
    |> cast(attrs, [:name, :first_name, :last_name, :company, :role, :bio, :avatar])
    |> validate_required([:name, :first_name, :last_name, :company, :role, :bio, :avatar])
    #|> foreign_key_constraint(:talk_id)
  end
end
