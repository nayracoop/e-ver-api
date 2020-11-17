defmodule EVerApi.EverTest do
  use EVerApi.DataCase

  alias EVerApi.Ever

  describe "events" do
    alias EVerApi.Ever.Event

    @valid_attrs %{
       summary: "some summary",
       end_time: "2010-04-17T14:00:00Z",
       name: "some name",
       start_time: "2010-04-17T14:00:00Z"
      }
    @update_attrs %{description: "some updated description", end_time: "2011-05-18T15:01:01Z", name: "some updated name", start_time: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{description: nil, end_time: nil, name: nil, start_time: nil}

    def event_fixture(attrs \\ %{}) do
      user = insert(:user)

      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put_new(:user_id, user.id)
        |> Ever.create_event()

      event
    end

    @tag individual_test: "list_events"
    test "list_events/0 returns all events" do
      event = event_fixture()
      [listed_event] = Ever.list_events()

      assert %{
        summary: "some summary",
        end_time: ~U[2010-04-17T14:00:00Z],
        name: "some name",
        start_time: ~U[2010-04-17T14:00:00Z]
       } = listed_event
    end

    @tag individual_test: "list_events"
    test "list_events/0 returns an empty list if there is no events" do
      assert [] == Ever.list_events()
    end

    @tag individual_test: "get_event"
    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert %{
        summary: "some summary",
        end_time: ~U[2010-04-17T14:00:00Z],
        name: "some name",
        start_time: ~U[2010-04-17T14:00:00Z]
       } = Ever.get_event!(event.id)

       assert_raise Ecto.NoResultsError, fn -> Ever.get_event!(-1) end
    end

    @tag individual_test: "get_event"
    test "get_event/1 returns the event with given id" do
      event = event_fixture()
      assert %{
        summary: "some summary",
        end_time: ~U[2010-04-17T14:00:00Z],
        name: "some name",
        start_time: ~U[2010-04-17T14:00:00Z]
       } = Ever.get_event(event.id)

       assert nil == Ever.get_event(-1)
    end

    @tag individual_test: "create_event"
    test "create_event/1 with valid data creates a event" do
      user = insert(:user)
      event_data = Map.put_new(@valid_attrs, :user_id, user.id)
      assert {:ok, %Event{} = event} = Ever.create_event(event_data)
      assert event.summary == "some summary"
      assert event.end_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert event.name == "some name"
      assert event.start_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    @tag individual_test: "create_event"
    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ever.create_event(@invalid_attrs)
    end

    @tag individual_test: "update_event"
    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Ever.update_event(event, @update_attrs)
      assert event.description == "some updated description"
      assert event.end_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert event.name == "some updated name"
      assert event.start_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    @tag individual_test: "update_event"
    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      user = event.user_id

      assert {:error, %Ecto.Changeset{}} = Ever.update_event(event, @invalid_attrs)

      not_updated_event = Ever.get_event!(event.id)
      assert not_updated_event.user_id == user
      assert %{
        summary: "some summary",
        end_time: ~U[2010-04-17T14:00:00Z],
        name: "some name",
        start_time: ~U[2010-04-17T14:00:00Z],
        description: nil
       } = not_updated_event
    end

    @tag individual_test: "delete_event"
    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Ever.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Ever.get_event!(event.id) end
    end

    @tag individual_test: "change_event"
    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Ever.change_event(event)
    end
  end

  describe "talks" do
    alias EVerApi.Ever.Talk

    @valid_attrs %{body: "some body", duration: 42, name: "some name", start_time: "2010-04-17T14:00:00Z", tags: [], video_url: "some video_url"}
    @update_attrs %{body: "some updated body", duration: 43, name: "some updated name", start_time: "2011-05-18T15:01:01Z", tags: [], video_url: "some updated video_url"}
    @invalid_attrs %{body: nil, duration: nil, name: nil, start_time: nil, tags: nil, video_url: nil}

    def talk_fixture(attrs \\ %{}) do
      {:ok, talk} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ever.create_talk()

      talk
    end

    test "list_talks/0 returns all talks" do
      talk = talk_fixture()
      assert Ever.list_talks() == [talk]
    end

    test "get_talk!/1 returns the talk with given id" do
      talk = talk_fixture()
      assert Ever.get_talk!(talk.id) == talk
    end

    test "create_talk/1 with valid data creates a talk" do
      assert {:ok, %Talk{} = talk} = Ever.create_talk(@valid_attrs)
      assert talk.body == "some body"
      assert talk.duration == 42
      assert talk.name == "some name"
      assert talk.start_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert talk.tags == []
      assert talk.video_url == "some video_url"
    end

    test "create_talk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ever.create_talk(@invalid_attrs)
    end

    test "update_talk/2 with valid data updates the talk" do
      talk = talk_fixture()
      assert {:ok, %Talk{} = talk} = Ever.update_talk(talk, @update_attrs)
      assert talk.body == "some updated body"
      assert talk.duration == 43
      assert talk.name == "some updated name"
      assert talk.start_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert talk.tags == []
      assert talk.video_url == "some updated video_url"
    end

    test "update_talk/2 with invalid data returns error changeset" do
      talk = talk_fixture()
      assert {:error, %Ecto.Changeset{}} = Ever.update_talk(talk, @invalid_attrs)
      assert talk == Ever.get_talk!(talk.id)
    end

    test "delete_talk/1 deletes the talk" do
      talk = talk_fixture()
      assert {:ok, %Talk{}} = Ever.delete_talk(talk)
      assert_raise Ecto.NoResultsError, fn -> Ever.get_talk!(talk.id) end
    end

    test "change_talk/1 returns a talk changeset" do
      talk = talk_fixture()
      assert %Ecto.Changeset{} = Ever.change_talk(talk)
    end
  end

  describe "speakers" do
    alias EVerApi.Ever.Speaker
    setup do
      e = insert(:event)
      #IO.inspect(e)
      %{event: e}
    end

    @valid_attrs %{avatar: "some avatar", bio: "some bio", company: "some company", first_name: "some first_name", last_name: "some last_name", name: "some name", role: "some role"}
    @update_attrs %{avatar: "some updated avatar", bio: "some updated bio", company: "some updated company", first_name: "some updated first_name", last_name: "some updated last_name", name: "some updated name", role: "some updated role"}
    @invalid_attrs %{avatar: nil, bio: nil, company: nil, first_name: nil, last_name: nil, name: nil, role: nil}

    def speaker_fixture(attrs \\ %{}) do
      {:ok, speaker} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ever.create_speaker()

      speaker
    end

    @tag individual_test: "list_speakers"
    test "list_speakers/0 returns all speakers", %{event: event} do

      new_speaker = speaker_fixture(%{event_id: event.id})
      # test with_undeleted
      deleted_speaker = speaker_fixture(%{event_id: event.id})
      Ever.delete_speaker(deleted_speaker)

      speakers = Ever.list_speakers()
      assert is_list(speakers)
      # 3 defined in factory and new_speaker
      assert Enum.count(speakers) == 4
      # validate a single speaker
      assert %{
        id: _,
        avatar: "some avatar",
        bio: "some bio",
        company: "some company",
        first_name: "some first_name",
        last_name: "some last_name",
        name: "some name",
        role: "some role"
      } = new_speaker
    end

    @tag individual_test: "get_speaker"
    test "get_speaker!/1 returns the speaker with given id", %{event: event} do
      speaker = speaker_fixture(%{event_id: event.id})
      assert Ever.get_speaker!(speaker.id) == speaker
    end

    @tag individual_test: "get_speaker"
    test "get_speaker/1 returns the speaker with given id", %{event: event} do
      speaker = speaker_fixture(%{event_id: event.id})
      assert Ever.get_speaker(speaker.id) == speaker
      # test nil in soft deleted speaker
      Ever.delete_speaker(speaker)
      assert Ever.get_speaker(speaker.id) == nil
      # nil
      assert Ever.get_speaker("666") == nil
    end

    test "create_speaker/1 with valid data creates a speaker" do
      assert {:ok, %Speaker{} = speaker} = Ever.create_speaker(@valid_attrs)
      assert speaker.avatar == "some avatar"
      assert speaker.bio == "some bio"
      assert speaker.company == "some company"
      assert speaker.first_name == "some first_name"
      assert speaker.last_name == "some last_name"
      assert speaker.name == "some name"
      assert speaker.role == "some role"
    end

    test "create_speaker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ever.create_speaker(@invalid_attrs)
    end

    test "update_speaker/2 with valid data updates the speaker" do
      speaker = speaker_fixture()
      assert {:ok, %Speaker{} = speaker} = Ever.update_speaker(speaker, @update_attrs)
      assert speaker.avatar == "some updated avatar"
      assert speaker.bio == "some updated bio"
      assert speaker.company == "some updated company"
      assert speaker.first_name == "some updated first_name"
      assert speaker.last_name == "some updated last_name"
      assert speaker.name == "some updated name"
      assert speaker.role == "some updated role"
    end

    test "update_speaker/2 with invalid data returns error changeset" do
      speaker = speaker_fixture()
      assert {:error, %Ecto.Changeset{}} = Ever.update_speaker(speaker, @invalid_attrs)
      assert speaker == Ever.get_speaker!(speaker.id)
    end

    test "delete_speaker/1 deletes the speaker" do
      speaker = speaker_fixture()
      assert {:ok, %Speaker{}} = Ever.delete_speaker(speaker)
      assert_raise Ecto.NoResultsError, fn -> Ever.get_speaker!(speaker.id) end
    end

    test "change_speaker/1 returns a speaker changeset" do
      speaker = speaker_fixture()
      assert %Ecto.Changeset{} = Ever.change_speaker(speaker)
    end
  end
end
