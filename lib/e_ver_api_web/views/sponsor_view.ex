defmodule EVerApiWeb.SponsorView do
  use EVerApiWeb, :view
  alias EVerApiWeb.SponsorView

  def render("index.json", %{sponsors: sponsors}) do
    %{data: render_many(sponsors, SponsorView, "sponsor.json")}
  end

  def render("show.json", %{sponsor: sponsor}) do
    %{data: render_one(sponsor, SponsorView, "sponsor.json")}
  end

  def render("sponsor.json", %{sponsor: sponsor}) do
    %{id: sponsor.id,
      name: sponsor.name,
      logo: sponsor.logo,
      website: sponsor.website}
  end
end
