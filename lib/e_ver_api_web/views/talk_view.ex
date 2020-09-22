defmodule EVerApiWeb.TalkView do
  use EVerApiWeb, :view
  alias EVerApiWeb.TalkView

  def render("index.json", %{talks: talks}) do
    %{data: render_many(talks, TalkView, "talk.json")}
  end

  def render("show.json", %{talk: talk}) do
    %{data: render_one(talk, TalkView, "talk.json")}
  end

  def render("talk.json", %{talk: talk}) do
    %{id: talk.id,
      name: talk.name,
      body: talk.body,
      start_time: talk.start_time,
      duration: talk.duration,
      video_url: talk.video_url,
      tags: talk.tags}
  end
end
