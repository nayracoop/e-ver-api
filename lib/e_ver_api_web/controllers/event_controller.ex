defmodule EVerApiWeb.EventController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Event

  action_fallback EVerApiWeb.FallbackController

  def index(conn, _params) do
    events = Ever.list_events()
    render(conn, "index.json", events: events)
  end

  def create(conn, %{"event" => event_params}) do
    with {:ok, %Event{} = event} <- Ever.create_event(event_params) do
      # manually adding event owner data ?

      conn
      |> put_status(:created)
      #|> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show_base.json", event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Ever.get_event!(id)
    render(conn, "show.json", event: event)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Ever.get_event!(id)

    with {:ok, %Event{} = event} <- Ever.update_event(event, event_params) do
      render(conn, "show.json", event: event)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Ever.get_event!(id)

    with {:ok, %Event{}} <- Ever.delete_event(event) do
      send_resp(conn, :no_content, "")
    end
  end
end