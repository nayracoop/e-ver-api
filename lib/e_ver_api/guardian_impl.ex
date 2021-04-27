defmodule EVerApi.Guardian do
  use Guardian, otp_app: :e_ver_api
  use Guardian.Permissions, encoding: Guardian.Permissions.BitwiseEncoding

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = EVerApi.Accounts.get_user!(id, :no_preloads)
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))

    {:ok, claims}
  end
end
