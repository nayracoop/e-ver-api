defmodule EVerApiWeb.TalkController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk
  alias EVerApiWeb.ControllerHelper

  action_fallback EVerApiWeb.FallbackController

  def action(conn, _) do
    args = [conn, conn.params, ControllerHelper.extract_user(conn)]
    apply(__MODULE__, action_name(conn), args)
  end

  # def index(conn, _params) do
  #   talks = Ever.list_talks()
  #   render(conn, "index.json", talks: talks)
  # end

  def create(conn, %{"event_id" => event_id, "talk" => talk_params}, current_user) do
    # Next time use Ecto relationship and update event

    case Ever.get_event(event_id, current_user) do
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

  def update(conn, %{"event_id" => event_id, "id" => id, "talk" => talk_params}, current_user) do
    case Ever.get_event(event_id, current_user) do
      nil ->  {:error, :not_found}
      event ->
        with talk when not is_nil(talk) <- Ever.get_talk(id),
        true <- is_valid_talk(talk, event.id),
        {:ok, %Talk{} = talk} <- Ever.update_talk(talk, talk_params) do
          render(conn, "show.json", talk: talk)
        else
          {:error,  %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}  # speaker not found
        end
    end
  end

  def delete(conn, %{"event_id" => event_id, "id" => id}, current_user) do
    case Ever.get_event(event_id, current_user) do
      nil ->  {:error, :not_found}
      event ->
        with talk when not is_nil(talk) <- Ever.get_talk(id),
        true <- is_valid_talk(talk, event.id),
        {:ok, %Talk{}} <- Ever.delete_talk(talk) do
          send_resp(conn, :no_content, "")
        else
          {:error,  %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}  # talk not found
        end
      end
  end

  defp is_valid_talk(talk, event_id) do
    talk.event_id == event_id
  end
end
