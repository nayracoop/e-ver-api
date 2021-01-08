defmodule EVerApiWeb.EventSchemaTest do
  use EVerApiWeb.ConnCase, async: true
  use Wormwood.GQLCase

  load_gql :get_events, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/GetEvents.gql"
  load_gql :get_event_by_id, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/GetEventById.gql"
  load_gql :create_event, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/CreateEvent.gql"

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, conn: conn, user: user}
  end

  describe "get events" do
    test "should return an empty list of Events when there are none", %{user: user} do
      result = query_gql_by(:get_events, context: %{current_user: user})
      assert {:ok, %{data: %{"events" => []}}} == result
    end

    test "should get all Events", %{user: user} do
      events = insert_list(3, :event)
      result = query_gql_by(:get_events, context: %{current_user: user})
      assert {:ok, %{data: %{"events" => events}}} = result
      assert Enum.count(events) == 3
    end

    test "should Authorize get all Events action" do
      events = insert_list(3, :event)
      result = query_gql_by(:get_events)
      assert {:ok, %{data: %{"events" => nil}, errors: [%{message: "Unauthorized"} | _]}} = result
    end
  end

  describe "get event by Id" do
    test "should get an Event by id with no user" do
      %{id: id} = insert(:event)
      id = Integer.to_string(id)
      result = query_gql_by(:get_event_by_id, variables: %{"id" => id})
      assert {:ok, %{data: %{"event" => %{"id" => ^id}}}} = result
    end
  end

  describe "create event" do
    test "should succesfully create an Event", %{user: user} do
      create_event_params = create_event_params()
      %{"name" => name, "description" => description} = create_event_params

      result = query_gql_by(
        :create_event,
        variables: %{
          "createEventParams" => create_event_params
        },
        context: %{current_user: user}
      )

      assert {:ok,
      %{
        data: %{
          "createEvent" => %{
            "name" => ^name,
            "description" => ^description
          }
        }
      }} = result
    end
  end
end
