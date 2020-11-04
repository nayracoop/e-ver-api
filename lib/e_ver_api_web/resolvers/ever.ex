defmodule EVerApiWeb.Resolvers.Ever do
  alias EVerApi.Ever

  def event(_, %{id: id}, _) do
    {:ok, Ever.get_event!(id)}
  end

  def events(_, _, _) do
    {:ok, Ever.list_events}
  end
end
