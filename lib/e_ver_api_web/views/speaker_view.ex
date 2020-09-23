defmodule EVerApiWeb.SpeakerView do
  use EVerApiWeb, :view
  alias EVerApiWeb.SpeakerView

  def render("index.json", %{speakers: speakers}) do
    %{data: render_many(speakers, SpeakerView, "speaker.json")}
  end

  def render("show.json", %{speaker: speaker}) do
    %{data: render_one(speaker, SpeakerView, "speaker.json")}
  end

  def render("speaker.json", %{speaker: speaker}) do
    %{id: speaker.id,
      name: speaker.name,
      first_name: speaker.first_name,
      last_name: speaker.last_name,
      company: speaker.company,
      role: speaker.role,
      bio: speaker.bio,
      avatar: speaker.avatar}
  end
end
