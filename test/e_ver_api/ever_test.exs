defmodule EVerApi.EverTest do
  use EVerApi.DataCase

  alias EVerApi.Ever

  describe "events" do
    alias EVerApi.Ever.Event

    @valid_attrs %{description: "some description", end_time: "2010-04-17T14:00:00Z", name: "some name", start_time: "2010-04-17T14:00:00Z"}
    @update_attrs %{description: "some updated description", end_time: "2011-05-18T15:01:01Z", name: "some updated name", start_time: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{description: nil, end_time: nil, name: nil, start_time: nil}

    def event_fixture(attrs \\ %{}) do
      {:ok, event} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Ever.create_event()

      event
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Ever.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Ever.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Ever.create_event(@valid_attrs)
      assert event.description == "some description"
      assert event.end_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert event.name == "some name"
      assert event.start_time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ever.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      assert {:ok, %Event{} = event} = Ever.update_event(event, @update_attrs)
      assert event.description == "some updated description"
      assert event.end_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert event.name == "some updated name"
      assert event.start_time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Ever.update_event(event, @invalid_attrs)
      assert event == Ever.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Ever.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Ever.get_event!(event.id) end
    end

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
end
