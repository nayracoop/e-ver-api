# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EVerApi.Repo.insert!(%EVerApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias EVerApi.Repo
alias EVerApi.Accounts.User

Repo.insert!(%User{
  first_name: "Richard",
  last_name: "Forte",
  organization: "The fake inc.",
  email: "rick.forte@fake.coop"
})

Repo.insert!(%User{
  first_name: "Dhavide",
  last_name: "Lebón",
  organization: "Coop Gerú Sirán",
  email: "dhavide.lebon@fake.coop"
})

Repo.insert!(%User{
  first_name: "señora",
  last_name: "nayra",
  organization: "Coop. de trabajo Nayra ltda",
  email: "nayra@fake.coop"
})
