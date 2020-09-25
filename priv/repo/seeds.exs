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
alias EVerApi.Ever.{Event, Talk, Speaker, Sponsor}

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


Repo.insert!(%Talk{
  title: "Why e-ver",
  details: "e-ver is a virtual events platform",
  summary: "e-ver demo",
  start_time: Timex.shift(now, days: 5),
  duration: 30,
  video: %{
    uri: "https://www.youtube.com/watch?v=C-u5WLJ9Yk4",
    type: "recorded",
    autoplay: false
  },
  event_id: 3
})

Repo.insert!(%Talk{
  title: "Creating a virtual event with e-ver",
  details: "e-ver virtual event creation process",
  summary: "creat a new e-ver",
  start_time: Timex.shift(now, days: 5, minutes: 30),
  duration: 20,
  video: %{
    uri: "https://www.youtube.com/watch?v=LyO2fU2cuec",
    type: "live"
  },
  event_id: 3,
  allow_comments: true,
  tags: ["virtual events", "e-ver"]
})


Repo.insert!(%Speaker{
  first_name: nil,
  last_name: nil,
  name: "nayrita coop",
  role: "cooperative",
  company: "nayra coop ltda",
  avatar: "nayra.png",
  talk_id: 1
})

Repo.insert!(%Speaker{
  first_name: "Cristina",
  last_name: "Laguardia",
  name: "Laguardia Cristina",
  role: "Kommander",
  company: "IMF",
  avatar: "nayra.png",
  talk_id: 1
})

Repo.insert!(%Speaker{
  first_name: "Mikel",
  last_name: "Louis",
  name: "Louis Mikel",
  role: "Ph D",
  company: "Paco Am Plus",
  avatar: "nayra.png",
  talk_id: 2
})

Repo.insert!(%Sponsor{
  name: "no name sponsor",
  logo: "no_name.png",
  website: "https://nayra.coop",
  event_id: 1
})

Repo.insert!(%Sponsor{
  name: "Fake Coop",
  logo: "no_name.png",
  website: "https://nayra.coop",
  event_id: 2
})

Repo.insert!(%Sponsor{
  name: "Fake Inc.",
  logo: "no_name.png",
  website: "https://nayra.coop",
  event_id: 2
})
