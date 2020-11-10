defmodule EVerApiWeb.SchemaTest do
  use EVerApiWeb.ConnCase
  use Wormwood.GQLCase

  load_gql :get_events, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/GetEvents.gql"
  load_gql :get_event_by_id, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/GetEventById.gql"

  setup %{conn: conn} do
    user = insert(:user)
    insert(:event)

    {:ok, jwt_string, _} = EVerApi.Accounts.token_sign_in("nayra@fake.coop", "123456")

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt_string}")

    {:ok, conn: conn, user: user}
  end

  describe "events" do
    test "should get all Events", %{user: user} do
      result = query_gql_by(:get_events, context: %{current_user: user})
      IO.inspect result, label: "RESULT"
      assert {:ok, _query_data} = result
    end

    test "should get an Event by id" do
      result = query_gql_by(:get_event_by_id, [])
      IO.inspect result, label: "RESULT"
      assert {:ok, _query_data} = result
    end
  end
end
