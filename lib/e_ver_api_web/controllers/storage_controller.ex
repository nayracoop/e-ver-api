defmodule EVerApiWeb.StorageController do
  use EVerApiWeb, :controller

  alias EVerApi.Storage.Picture
  alias EVerApi.Storage

  def create(conn, picture_params) do
    IO.inspect(picture_params, label: "file")
    case Storage.create_picture(picture_params) do
      {:ok, picture} ->
        IO.inspect(picture)
        conn
          |> put_status(:created)
      {:error, %Ecto.Changeset{errors: error} = changeset} ->
        IO.inspect("error uploading photo")
        IO.inspect(error)
    end

  end

  def show(conn, _params) do
    conn
  end

end
