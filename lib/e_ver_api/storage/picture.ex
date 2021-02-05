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
    IO.inspect(picture, label: "picture")
    IO.inspect(attrs, label: "attrs")
    attrs = add_timestamp(attrs)
    picture
    |> cast(attrs, [:title])
    |> cast_attachments(attrs, [:image])
    |> validate_required([:title, :image])
  end

  defp add_timestamp(%{"image" => %Plug.Upload{filename: name} = image} = attrs) do
    image = %Plug.Upload{image | filename: prepend_timestamp(name)}
    %{attrs | "image" => image}
  end

  defp prepend_timestamp(name) do
    "#{:os.system_time()}" <> name
  end
end
