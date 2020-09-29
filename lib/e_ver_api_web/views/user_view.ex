defmodule EVerApiWeb.UserView do
  use EVerApiWeb, :view
  alias EVerApiWeb.{UserView, EventView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show_base.json", %{user: user}) do
    %{data: render_one(user, UserView, "base_user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      username: user.username,
      organization: user.organization,
      events: render_many(user.events, EventView, "base_event.json")
    }
  end

  def render("base_user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      username: user.username,
      organization: user.organization
    }
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
