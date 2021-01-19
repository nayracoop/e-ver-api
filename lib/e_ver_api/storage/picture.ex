defmodule EVerApi.Storage.Picture do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias EVerApi.Storage.ImageUploader
  alias EVerApi.Storage.Picture

  schema "pictures" do
    field :image, ImageUploader.Type
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Picture{} = picture, attrs) do
    picture
    |> cast(attrs, [:title])
    |> cast_attachments(attrs, [:image])
    |> validate_required([:title, :image])
  end
end
