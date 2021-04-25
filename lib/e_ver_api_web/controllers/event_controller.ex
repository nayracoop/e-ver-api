defmodule EVerApiWeb.EventController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Event
  alias EVerApiWeb.ControllerHelper

  action_fallback EVerApiWeb.FallbackController

  def action(conn, _) do
    args = [conn, conn.params, ControllerHelper.extract_user(conn)]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    events = Ever.list_events(current_user)
    render(conn, "index.json", events: events)
  end

  def create(conn, %{"event" => event_params}, _current_user) do
    user = conn.private.guardian_default_resource
    with {:ok, %Event{} = event} <- Ever.create_event(event_params, user) do
      # manually adding event owner data ?

      conn
      |> put_status(:created)
      #|> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show_base.json", event: event)
    end
  end

  def show(conn, %{"id" => id}, _) do
    event = Ever.get_event(id)
    case event do
      nil -> {:error, :not_found}
      _ -> render(conn, "show.json", event: event)
    end
  end

  def update(conn, %{"id" => id, "event" => event_params}, current_user) do
    case Ever.get_event(id, current_user) do
      nil ->  {:error, :not_found}
      event ->
        with {:ok, %Event{} = event} <- Ever.update_event(event, event_params) do
          render(conn, "show.json", event: event)
        end
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    with event when not is_nil(event) <- Ever.get_event(id, current_user),
        {:ok, %Event{}}  <- Ever.delete_event(event) do
      send_resp(conn, :no_content, "")
    else
      _ -> {:error, :not_found}
    end
  end
end
