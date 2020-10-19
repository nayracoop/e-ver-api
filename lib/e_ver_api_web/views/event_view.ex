defmodule EVerApiWeb.EventView do
  use EVerApiWeb, :view
  alias EVerApiWeb.{EventView, UserView, TalkView, SponsorView}

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("show_base.json", %{event: event}) do
    %{data: render_one(event, EventView, "base_event.json")}
  end

  def render("event.json", %{event: event}) do
    IO.inspect(event)
    %{id: event.id,
      name: event.name,
      summary: event.summary,
      description: event.description,
      start_time: event.start_time,
      end_time: event.end_time,
      user: render_one(event.user, UserView, "base_user.json"),
      talks: render_many(event.talks, TalkView, "talk.json"),
      sponsors: render_many(event.sponsors, SponsorView, "sponsor.json")
    }
  end

  def render("base_event.json", %{event: event}) do
    %{id: event.id,
      name: event.name,
      summary: event.summary,
      description: event.description,
      start_time: event.start_time,
      end_time: event.end_time,
      user_id: event.user_id
    }
  end
end
