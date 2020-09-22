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

    timestamps()
  end

  @doc false
  def changeset(talk, attrs) do
    talk
    |> cast(attrs, [:name, :body, :start_time, :duration, :video_url, :tags])
    |> validate_required([:name, :body, :start_time, :duration, :video_url, :tags])
  end
end
