defmodule EVerApi.Ever.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :end_time, :utc_datetime
    field :name, :string
    field :start_time, :utc_datetime

    belongs_to :user, EVerApi.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :start_time, :end_time, :user_id])
    |> validate_required([:name, :description, :start_time, :end_time, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
