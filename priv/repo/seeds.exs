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
alias EVerApi.Ever.Event

now = Timex.now |> Timex.to_datetime() |> DateTime.truncate(:second)

Repo.insert!(%User{
  first_name: "señora",
  last_name: "nayra",
  organization: "Coop. de trabajo Nayra ltda",
  email: "nayra@fake.coop"
})

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

Repo.insert!(%Event{
  name: "VR/AR the state of art",
  description: "Fake event for e-ver demo purpose",
  start_time: Timex.shift(now, days: 15),
  end_time: Timex.shift(now, days: 18),
  user_id: 1
})

Repo.insert!(%Event{
  name: "AI für alles! a non scientific AI aproach",
  description: "Full event for e-ver demo purpose",
  start_time: Timex.shift(now, months: 1),
  end_time: Timex.shift(now, months: 1, hours: 5),
  user_id: 2
})

Repo.insert!(%Event{
  name: "Ever Demo Event",
  description: "Full event for e-ver demo purpose",
  start_time: Timex.shift(now, days: 5),
  end_time: Timex.shift(now, days: 6),
  user_id: 1
})
