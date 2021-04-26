defmodule EVerApi.Ever.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.SoftDelete.Schema

  schema "messages" do
    field :body, :string

    belongs_to :talk, EVerApi.Ever.Talk
    belongs_to :user, EVerApi.Accounts.User
    soft_delete_schema()

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
