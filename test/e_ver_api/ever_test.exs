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
end
