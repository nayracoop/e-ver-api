defmodule EVerApiWeb.AuthorizationPipeline  do
  use Guardian.Plug.Pipeline, otp_app: :e_ver_api,
  module: EVerApi.Guardian,
  error_handler: EVerApiWeb.AuthorizationErrorHandler

  plug Guardian.Permissions, ensure: %{admin: [:read, :write]}
end
