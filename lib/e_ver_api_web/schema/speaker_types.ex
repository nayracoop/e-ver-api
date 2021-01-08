defmodule EVerApiWeb.Schema.SpeakerTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias EVerApi.Ever

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
end
