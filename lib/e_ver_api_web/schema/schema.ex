defmodule EVerApiWeb.Schema.Schema do
  use Absinthe.Schema

  import_types EVerApiWeb.Schema.EventTypes
  import_types EVerApiWeb.Schema.GlobalTypes
  import_types EVerApiWeb.Schema.SpeakerTypes
  import_types EVerApiWeb.Schema.SponsorTypes
  import_types EVerApiWeb.Schema.TalkTypes
  import_types EVerApiWeb.Schema.UserTypes
  import_types Absinthe.Type.Custom

  alias EVerApi.{Accounts, Ever, Sponsors}

  query do
    import_fields :event_queries
  end

  mutation do
    import_fields :event_mutations
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
