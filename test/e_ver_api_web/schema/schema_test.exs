defmodule EVerApiWeb.SchemaTest do
  use EVerApiWeb.ConnCase
  use Wormwood.GQLCase

  load_gql :get_events, EVerApiWeb.Schema.Schema, "test/e_ver_api_web/schema/queries/GetEvents.gql"

  test "should be a valid query" do
    result = query_gql(:get_events, variables: %{}, context: %{})
    assert {:ok, _query_data} = result
  end
end
