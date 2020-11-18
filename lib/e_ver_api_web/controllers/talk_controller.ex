defmodule EVerApiWeb.TalkController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk

  action_fallback EVerApiWeb.FallbackController

  # def index(conn, _params) do
  #   talks = Ever.list_talks()
  #   render(conn, "index.json", talks: talks)
  # end

  def create(conn, %{"event_id" => event_id, "talk" => talk_params}) do
    # Next time use Ecto relationship and update event

    case Ever.get_event(event_id) do
      nil ->  {:error, :not_found}
      event ->
        params = Map.put_new(talk_params, "event_id", event.id)
        with {:ok, %Talk{} = talk} <- Ever.create_talk(params) do
          conn
          |> put_status(:created)
          |> render("show.json", talk: talk)
        end
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
