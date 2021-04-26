defmodule EVerApiWeb.TalkChannel do
  import Ecto.Query, warn: false
  use EVerApiWeb, :channel
  alias EverApi.Accounts
  alias EverApi.Ever
  alias EVerApiWeb.MessageView

  def join("talk:" <> talk_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    talk_id = String.to_integer(talk_id)
    talk = Ever.get_talk!(talk_id)

    messages =
      EverApi.Repo.all(
        from m in Ecto.assoc(talk, :messages),
          where: m.id > ^last_seen_id,
          order_by: [asc: m.inserted_at, asc: m.id],
          limit: 200,
          preload: [:user]
      )

    resp = %{
      messages: Phoenix.View.render_many(messages, MessageView, "message.json")
    }

    {:ok, resp, assign(socket, :talk_id, talk_id)}
  end

  def handle_in("new_message", params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)

    changeset =
      user
      |> Ecto.build_assoc(:messages, talk_id: socket.assigns.talk_id)
      |> EverApi.Ever.Message.changeset(params)

    case EverApi.Repo.insert(changeset) do
      {:ok, message} ->
        broadcast!(socket, "new_message", %{
          id: message.id,
          user: EVerApiWeb.UserView.render("base_user.json", %{user: user}),
          body: message.body,
          inserted_at: message.inserted_at
        })

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
