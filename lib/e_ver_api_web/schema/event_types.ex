defmodule EVerApiWeb.Schema.EventTypes do
  @moduledoc false
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias EVerApiWeb.Resolvers.Event, as: EventResolver
  alias EVerApiWeb.Schema.Middleware
  alias EVerApi.{Accounts, Ever, Sponsors}

  object :event, description: "an e-ver event" do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, :string
    field :summary, non_null(:string)
    field :url, :string
    field :start_time, non_null(:datetime)
    field :end_time, non_null(:datetime)

    field :user, non_null(:user), resolve: dataloader(Accounts)
    field :talks, list_of(:talk), resolve: dataloader(Ever)
    field :speakers, list_of(:speaker), resolve: dataloader(Ever)
    field :sponsors, list_of(:sponsor), resolve: dataloader(Sponsors)
  end

  input_object :create_event_params, description: "create an event" do
    field :name, non_null(:string)
    field :description, :string
    field :summary, non_null(:string)
    field :url, :string
    field :start_time, non_null(:datetime)
    field :end_time, non_null(:datetime)
  end

  object :event_mutations do
    field :create_event, type: :event, description: "create a new event" do
      arg :create_event_params, :create_event_params
      middleware Middleware.Authenticate
      resolve &EventResolver.create_event/3
    end
  end

  object :event_queries do
    field :event, type: :event, description: "get an event by its id" do
      arg :id, non_null(:id)
      resolve &EventResolver.get_event/3
    end

    field :events, type: list_of(:event), description: "get a list of events" do
      arg :order, type: :sort_order, default_value: :asc
      middleware Middleware.Authenticate
      resolve &EventResolver.list_events/3
    end
  end
end
