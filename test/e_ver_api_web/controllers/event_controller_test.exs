defmodule EVerApiWeb.EventControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Event

  @create_attrs %{
    summary: "some summary",
    end_time: "2010-04-17T14:00:00Z",
    name: "some name",
    start_time: "2010-04-17T14:00:00Z",
    user_id: 1
  }
  @update_attrs %{
    description: "some updated description",
    end_time: "2011-05-18T15:01:01Z",
    name: "some updated name",
    start_time: "2011-05-18T15:01:01Z"
  }
  @invalid_attrs %{description: nil, end_time: nil, name: nil, start_time: nil}

  defp assert_401(conn, f, route) do
    conn =
      conn
      |> delete_req_header("authorization")
      |> f.(route)
    assert json_response(conn, 401)["message"] == "unauthenticated"
  end

  def fixture(:event) do
    {:ok, event} = Ever.create_event(@create_attrs)
    event
  end

  setup %{conn: conn} do
    insert(:user)
    jwt = EVerApi.Accounts.token_sign_in("nayra@fake.coop", "123456")
    {:ok, jwt_string, _} = jwt
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt_string}")

    {:ok, conn: conn}
  end

  describe "index" do
    #setup []

    @tag individual_test: "events_index"
    test "401 for list events", %{conn: conn} do
      assert_401(conn, &get/2, Routes.event_path(conn, :index))
    end

    @tag individual_test: "events_index"
    test "lists all events", %{conn: conn} do
      e = fixture(:event)

      conn = get(conn, Routes.event_path(conn, :index))
      assert json_response(conn, 200)
      response = json_response(conn, 200)["data"]
      assert [%{
        "summary" => "some summary",
        "end_time" => "2010-04-17T14:00:00Z",
        "name" => "some name",
        "start_time" => "2010-04-17T14:00:00Z"
      }] = response
    end

    @tag individual_test: "events_index"
    test "renders an empty array of events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert json_response(conn, 200)
      response = json_response(conn, 200)["data"]
      assert [] == response
    end
  end

  describe "show" do
    setup [:create_event]

    @tag individual_test: "events_show"
    test "get an event by id", %{conn: conn} do
      event = fixture(:event)
      conn = get(conn, Routes.event_path(conn, :show, event.id))

      assert json_response(conn, 200)

      response = json_response(conn, 200)["data"]
      assert %{
        "summary" => "some summary",
        "end_time" => "2010-04-17T14:00:00Z",
        "name" => "some name",
        "start_time" => "2010-04-17T14:00:00Z"
      } = response
    end

    @tag individual_test: "events_show"
    # can get an event without JWT - in the "future" should use domain check logic
    test "get an event by id without authentication", %{conn: conn} do
      event = fixture(:event)
      conn = delete_req_header(conn, "authorization")
      conn = get(conn, Routes.event_path(conn, :show, event.id))

      assert json_response(conn, 200)

      response = json_response(conn, 200)["data"]
      assert %{
        "summary" => "some summary",
        "end_time" => "2010-04-17T14:00:00Z",
        "name" => "some name",
        "start_time" => "2010-04-17T14:00:00Z"
      } = response
    end


    @tag individual_test: "events_show"
    test "404 for get an event by id", %{conn: conn} do
      event = fixture(:event)
      conn = get(conn, Routes.event_path(conn, :show, -1))

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  describe "create event" do
    @tag individual_test: "events_create"
    test "401 for create an event", %{conn: conn} do
      assert_401(conn, &post/2, Routes.event_path(conn, :create))
    end

    @tag individual_test: "events_create"
    test "renders event when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_path(conn, :show, id))

      assert %{
               "id" => id,
               "summary" => "some summary",
               "end_time" => "2010-04-17T14:00:00Z",
               "name" => "some name",
               "start_time" => "2010-04-17T14:00:00Z"
             } = json_response(conn, 200)["data"]
    end

    @tag individual_test: "events_create"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event" do
    setup [:create_event]

    test "renders event when data is valid", %{conn: conn, event: %Event{id: id} = event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.event_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "end_time" => "2011-05-18T15:01:01Z",
               "name" => "some updated name",
               "start_time" => "2011-05-18T15:01:01Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, Routes.event_path(conn, :delete, event))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_path(conn, :show, event))
      end
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end
end
