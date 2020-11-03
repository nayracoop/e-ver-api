defmodule EVerApi.Sponsors.Sponsor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sponsors" do
    field :logo, :string
    field :name, :string
    field :website, :string

    belongs_to :event, EVerApi.Ever.Event

    timestamps()
  end

  @doc false
  def changeset(sponsor, attrs) do
    sponsor
    |> cast(attrs, [:name, :logo, :website, :event_id])
    |> validate_required([:name, :logo, :website, :event_id])
  end
end
