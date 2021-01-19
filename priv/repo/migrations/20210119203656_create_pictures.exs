defmodule EVerApi.Repo.Migrations.CreatePictures do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :title, :string
      add :image, :string

      timestamps()
    end

  end
end
