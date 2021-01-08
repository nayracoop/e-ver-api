defmodule EVerApiWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias EVerApi.Ever

  object :user do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :organization, non_null(:string)
    field :username, non_null(:string)
    field :email, non_null(:string)

    field :events, list_of(:event), resolve: dataloader(Ever)
  end
end
