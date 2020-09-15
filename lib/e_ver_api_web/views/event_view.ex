defmodule EVerApiWeb.EventView do
  use EVerApiWeb, :view
  alias EVerApiWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      name: event.name,
      description: event.description,
      start_time: event.start_time,
      end_time: event.end_time}
  end
end
