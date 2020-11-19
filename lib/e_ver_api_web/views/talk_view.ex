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
      video: video(talk.video),
      tags: talk.tags,
      allow_comments: talk.allow_comments,
      speakers: render_many(speakers(talk.speakers), SpeakerView, "speaker.json")}
  end

  defp speakers(%Ecto.Association.NotLoaded{}), do: []
  defp speakers(s), do: s

  defp video(nil), do: %{uri: nil, type: nil, autoplay: nil}
  defp video(v = %{}), do: %{uri: v.uri, type: v.type, autoplay: v.autoplay}
end
