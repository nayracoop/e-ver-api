defmodule EVerApi.Ever.Event do
  use Ecto.Schema
  import Ecto.SoftDelete.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :description, :string
    field :summary, :string
    field :url, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    soft_delete_schema()

    belongs_to :user, EVerApi.Accounts.User
    has_many :talks, EVerApi.Ever.Talk
    has_many :speakers, EVerApi.Ever.Speaker
    has_many :sponsors, EVerApi.Sponsors.Sponsor

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :summary, :description, :url, :start_time, :end_time, :user_id])
    |> validate_required([:name, :summary, :start_time, :end_time, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_length(:summary, min: 2, max: 512)
    #|> validate_length(:description, min: 2)
    # validate utc datetime fields
  end
end
