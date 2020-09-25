defmodule EVerApi.Ever.Video do
  use Ecto.Schema

  embedded_schema do
    field :uri, :string
    field :type, :string
    field :autoplay, :boolean, default: true
  end
end
