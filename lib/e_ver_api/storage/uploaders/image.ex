defmodule EVerApi.Storage.ImageUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  def storage_dir(_version, {_,_}) do
    if Mix.env == :test do
      "uploads/test"
    else
      "uploads"
    end
  end
end
