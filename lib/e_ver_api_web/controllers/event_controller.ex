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
    event = Ever.get_event(id)
    case event do
      nil -> {:error, :not_found}
      _ -> render(conn, "show.json", event: event)
    end
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    case Ever.get_event(id) do
      nil ->  {:error, :not_found}
      event ->
        with {:ok, %Event{} = event} <- Ever.update_event(event, event_params) do
          render(conn, "show.json", event: event)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    with event when not is_nil(event) <- Ever.get_event(id),
        {:ok, %Event{}}  <- Ever.delete_event(event) do
      send_resp(conn, :no_content, "")
    else
      _ -> {:error, :not_found}
    end
  end
end
