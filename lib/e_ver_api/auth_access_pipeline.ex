defmodule EVerApi.AuthAccessPipeline  do
  use Guardian.Plug.Pipeline, otp_app: :e_ver_api

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
