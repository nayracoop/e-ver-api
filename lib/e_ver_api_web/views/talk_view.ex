defmodule EVerApiWeb.TalkView do
  use EVerApiWeb, :view
  alias EVerApiWeb.{TalkView, SpeakerView}

  def render("index.json", %{talks: talks}) do
    %{data: render_many(talks, TalkView, "talk.json")}
  end

  def render("show.json", %{talk: talk}) do
    %{data: render_one(talk, TalkView, "talk.json")}
  end

  def render("talk.json", %{talk: talk}) do
    %{id: talk.id,
      title: talk.title,
      details: talk.details,
      summary: talk.summary,
      start_time: talk.start_time,
      duration: talk.duration,
      video: %{uri: talk.video.uri, type: talk.video.type, autoplay: talk.video.autoplay},
      tags: talk.tags,
      speakers: render_many(talk.speakers, SpeakerView, "speaker.json")}
  end
end
