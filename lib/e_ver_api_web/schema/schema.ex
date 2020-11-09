defmodule EVerApiWeb.Schema.Schema do
  use Absinthe.Schema
  alias EVerApi.{Accounts, Ever, Sponsors}

  import_types Absinthe.Type.Custom
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias EVerApiWeb.Resolvers
  alias EVerApiWeb.Schema.Middleware

  query do
    @desc "Get an event by its id"
    field :event, :event do
      arg(:id, non_null(:id))
      resolve &Resolvers.Ever.event/3
    end

    @desc "Get a list of events"
    field :events, list_of(:event) do
      arg :order, type: :sort_order, default_value: :asc
      middleware Middleware.Authenticate
      resolve &Resolvers.Ever.events/3
    end
  end

  mutation do
    @desc "Create an event"
    field :create_event, :event do
      arg :name, non_null(:string)
      arg :description, non_null(:string)
      arg :summary, non_null(:string)
      arg :url, non_null(:string)
      arg :start_time, non_null(:datetime)
      arg :end_time, non_null(:datetime)
      middleware Middleware.Authenticate
      resolve &Resolvers.Ever.create_event/3
    end
  end

  enum :sort_order do
    value :asc
    value :desc
  end

  object :event do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :summary, non_null(:string)
    field :url, non_null(:string)
    field :start_time, non_null(:datetime)
    field :end_time, non_null(:datetime)

    field :user, non_null(:user), resolve: dataloader(Accounts)

    field :talks, list_of(:talk), resolve: dataloader(Ever)
    field :speakers, list_of(:speaker), resolve: dataloader(Ever)
    field :sponsors, list_of(:sponsor), resolve: dataloader(Sponsors)
  end

  object :talk do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :details, non_null(:string)
    field :summary, non_null(:string)
    field :start_time, non_null(:datetime)
    field :duration, non_null(:integer)
    field :tags, list_of(:string)
    field :allow_comments, non_null(:boolean)

    field :speakers, list_of(:speaker), resolve: dataloader(Ever)
  end

  object :speaker do
    field :id, non_null(:id)
    field :avatar, non_null(:string)
    field :bio, non_null(:string)
    field :company, non_null(:string)
    field :first_name, :string
    field :last_name, :string
    field :name, non_null(:string)
    field :role, :string

    field :talks, list_of(:talk), resolve: dataloader(Ever)
  end

  object :sponsor do
    field :id, non_null(:id)
    field :logo, non_null(:string)
    field :name, non_null(:string)
    field :website, non_null(:string)
  end

  object :user do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :organization, non_null(:string)
    field :username, non_null(:string)
    field :email, non_null(:string)
  end

  def context(ctx) do
    loader =
      Dataloader.new
      |> Dataloader.add_source(Accounts, Accounts.datasource())
      |> Dataloader.add_source(Ever, Ever.datasource())
      |> Dataloader.add_source(Sponsors, Sponsors.datasource())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
