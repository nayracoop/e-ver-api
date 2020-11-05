defmodule EVerApiWeb.SetCurrentUser do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    maybe_user = Guardian.Plug.current_resource(conn)

    context = %{current_user: maybe_user}
    Absinthe.Plug.put_options(conn, context: context)
  end
end
