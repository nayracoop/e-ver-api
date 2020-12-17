defmodule EVerApiWeb.AuthorizationErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, opts) do
    body = Jason.encode!(%{message: to_string(type)})

    # using resp instead of send_resp avoids Plug.Conn.AlreadySentError exeption

    conn
    |> put_resp_content_type("text/json")
    |> Guardian.Plug.maybe_halt(opts)
    #|> send_resp(403, body)
    |> resp(403, body)
  end
end
