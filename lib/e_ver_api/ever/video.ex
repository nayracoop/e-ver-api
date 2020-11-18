defmodule EVerApi.Ever.Video do
  use Ecto.Schema

  embedded_schema do
    field :uri, :string, default: nil
    field :type, :string, default: nil
    field :autoplay, :boolean, default: true
  end
end
