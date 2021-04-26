defmodule EVerApiWeb.MessageView do
  use EVerApiWeb, :view

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      body: message.body,
      user: render_one(message.user, EVerApiWeb.UserView, "base_user.json")
    }
  end
end
