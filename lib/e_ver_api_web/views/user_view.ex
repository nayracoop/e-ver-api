defmodule EVerApiWeb.UserView do
  use EVerApiWeb, :view
  alias EVerApiWeb.{UserView, EventView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "base_user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      organization: user.organization,
      events: %{data: render_many(user.events, EventView, "base_event.json")}
    }
  end

  def render("base_user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      organization: user.organization
    }
  end
end
