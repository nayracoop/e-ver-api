defmodule EVerApi.Factory do
  use ExMachina.Ecto, repo: EVerApi.Repo
  import Bcrypt, only: [hash_pwd_salt: 1]

  def user_factory do
    hash = hash_pwd_salt("123456");

    %EVerApi.Accounts.User{
      first_name: "señora",
      last_name: "nayra",
      organization: "Coop. de trabajo Nayra ltda",
      email: "nayra@fake.coop",
      username: "nayra",
      password_hash: hash,
      id: 1 # fixed id for test
    }
  end
end
