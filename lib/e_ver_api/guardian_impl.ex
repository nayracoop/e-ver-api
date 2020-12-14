defmodule  EVerApi.Guardian do
  use Guardian, otp_app: :e_ver_api
  use Guardian.Permissions, encoding: Guardian.Permissions.BitwiseEncoding

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end


  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = EVerApi.Accounts.get_user!(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))
    {:ok, claims}
  end
end
