defmodule EVerApi.Repo do
  use Ecto.Repo,
    otp_app: :e_ver_api,
    adapter: Ecto.Adapters.Postgres
end
