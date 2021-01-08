defmodule EVerApiWeb.Schema.TalkTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias EVerApi.Ever

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
end
