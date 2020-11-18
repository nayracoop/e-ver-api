defmodule EVerApiWeb.Resolvers.Event do
  alias EVerApi.Ever
  alias EVerApiWeb.Schema.ChangesetErrors

  def get_event(_, %{id: id}, _) do
    {:ok, Ever.get_event(id)}
  end

  def list_events(_, _, _) do
    {:ok, Ever.list_events_no_preload}
  end

  def create_event(_, %{create_event_input: args}, %{context: %{current_user: user}}) do
    case Ever.create_event(user, args) do
      {:error, changeset} ->
        {
          :error,
          message: "Error creating event",
          details: ChangesetErrors.error_details(changeset)
        }

      {:ok, event} ->
        {:ok, event}
    end
  end
end
