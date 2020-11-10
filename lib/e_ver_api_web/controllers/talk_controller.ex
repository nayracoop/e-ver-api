defmodule EVerApiWeb.TalkController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk

  action_fallback EVerApiWeb.FallbackController

  # def index(conn, _params) do
  #   talks = Ever.list_talks()
  #   render(conn, "index.json", talks: talks)
  # end

  def create(conn, %{"talk" => talk_params}) do
    with {:ok, %Talk{} = talk} <- Ever.create_talk(talk_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.talk_path(conn, :show, talk))
      |> render("show.json", talk: talk)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   talk = Ever.get_talk!(id)
  #   render(conn, "show.json", talk: talk)
  # end

  def update(conn, %{"id" => id, "talk" => talk_params}) do
    talk = Ever.get_talk!(id)

    with {:ok, %Talk{} = talk} <- Ever.update_talk(talk, talk_params) do
      render(conn, "show.json", talk: talk)
    end
  end

  def delete(conn, %{"id" => id}) do
    talk = Ever.get_talk!(id)

    with {:ok, %Talk{}} <- Ever.delete_talk(talk) do
      send_resp(conn, :no_content, "")
    end
  end
end
