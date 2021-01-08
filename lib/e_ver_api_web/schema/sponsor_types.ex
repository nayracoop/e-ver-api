defmodule EVerApiWeb.Schema.SponsorTypes do
  use Absinthe.Schema.Notation

  object :sponsor do
    field :id, non_null(:id)
    field :logo, non_null(:string)
    field :name, non_null(:string)
    field :website, non_null(:string)
  end
end
