defmodule EVerApi.Factory do
  use ExMachina.Ecto, repo: EVerApi.Repo
  alias ExMachina.Sequence
  import Bcrypt, only: [hash_pwd_salt: 1]

  @names ["Richard", "Feche", "Elsa", "Refalosa", "Quiqui", "Ana", "Raquel", "Pablito", "Wenceslao", "Abel"]
  @topics ["programming in KOVOL", "Decentralized life",
    "Cooperativismo mágico", "Sound sculptures", "Wine & enology",
    "Innovation in Media Arts", "AR/VR für alles", "Innovationsgenossenschaften",
    "The void in XXI Century litterature", "Tout est virtuel"
  ]
  @roles ["Supreme King", "A simple human", "AI chief", "CEO", "Inventor", "PO", "Evangelist"]
  @sponsors ["The Air Conditioner Fundamentalism co.", "nayracoop"]

  def user_factory do
    %EVerApi.Accounts.User{
      first_name: "señora",
      last_name: "nayra",
      organization: "Coop. de trabajo Nayra ltda",
      email: sequence(:email, &"email-#{&1}@example.com"),
      username: sequence("nayra"),
      password_hash: hash_pwd_salt("123456"),
      permissions: %{admin: [:read, :write]}
    }
  end

  def speaker_factory do
    %EVerApi.Ever.Speaker{
      name: Sequence.next(:names, @names),
      first_name: Sequence.next(:names, @names),
      last_name: Sequence.next(:names, @names),
      role: Sequence.next(:role, @roles)
    }
  end

  def talk_factory do
    %EVerApi.Ever.Talk{
      title: Sequence.next(:topics, @topics),
      video: %{} #TODO
    }
  end

  # def speaker_talk_factory do
  #   %EVerApi.Ever.SpeakerTalk{
  #     speaker_id: nil,
  #     talk_id: nil
  #   }
  # end

  def sponsor_factory do
    %EVerApi.Sponsors.Sponsor{
      logo: "an_img_url.png",
      name: Sequence.next(:sponsors, @sponsors),
      website: "nayra.coop"
    }
  end

  def event_factory do
    # speaker & talks
    [speaker | speakers] = insert_list(3, :speaker)

    talk1 = build(:talk, %{speakers: [speaker, List.first(speakers)]})
    talk2 = build(:talk,  %{speakers: [List.first(speakers)]})
    talk3 = build(:talk)
    # NOTE an orphan speaker exists

    #sponsor
    sponsors = insert_list(2, :sponsor)

    %EVerApi.Ever.Event{
      summary: "some summary",
      end_time: "2010-04-17T14:00:00Z",
      name: Sequence.next(:topics, @topics),
      start_time: "2010-04-17T14:00:00Z",
      user: build(:user),
      talks: [talk1, talk2, talk3],
      speakers: Enum.concat([speaker], speakers),
      sponsors: sponsors
    }
  end
end
