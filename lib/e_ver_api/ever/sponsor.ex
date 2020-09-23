defmodule EVerApi.Ever.Sponsor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sponsors" do
    field :logo, :string
    field :name, :string
    field :website, :string

    timestamps()
  end

  @doc false
  def changeset(sponsor, attrs) do
    sponsor
    |> cast(attrs, [:name, :logo, :website])
    |> validate_required([:name, :logo, :website])
  end
end
