defmodule EVerApiWeb.Schema.Middleware.Authenticate do
  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    IO.inspect resolution.context

    case resolution.context do
      %{current_user: user} when user != nil ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Unauthorized"})
    end
  end
end
