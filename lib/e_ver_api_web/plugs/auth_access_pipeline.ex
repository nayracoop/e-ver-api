defmodule EVerApiWeb.AuthAccessPipeline  do
  use Guardian.Plug.Pipeline, otp_app: :e_ver_api,
                              module: EVerApi.Guardian

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
