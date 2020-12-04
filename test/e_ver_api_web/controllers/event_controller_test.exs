defmodule EVerApiWeb.EventControllerTest do
  use EVerApiWeb.ConnCase, async: true
  @moduletag :events_controller_case

  alias EVerApi.Ever
  alias EVerApi.Ever.Event

  @create_attrs %{
    summary: "some summary",
    end_time: "2010-04-17T14:00:00Z",
    name: "some name",
    start_time: "2010-04-17T14:00:00Z"
  }
  @update_attrs %{
    description: "some updated description",
    end_time: "2011-05-18T15:01:01Z",
    name: "some updated name",
    start_time: "2011-05-18T15:01:01Z"
  }
  @invalid_attrs %{description: nil, end_time: nil, name: nil, start_time: nil}

  describe "with a logged-in user" do
    setup %{conn: conn, login_as: email} do
      user = insert(:user, email: email)

      # other user and event for this user
      evil_user = insert(:user, %{first_name: "Mauricio"})
      evil_event = insert(:event, %{name: "¡No more inundations!", user: evil_user})

      {:ok, jwt_string, _} = EVerApi.Accounts.token_sign_in(email, "123456")

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt_string}")

      {:ok, conn: conn, user: user, evil_event: evil_event, evil_user: evil_user}
    end
    # INDEX
    @tag individual_test: "events_index", login_as: "email@email.com"
    test "lists all events (with related data)", %{conn: conn, user: user} do
      e = insert(:event, user: user)

      conn = get(conn, Routes.event_path(conn, :index))
      response = json_response(conn, 200)["data"]
      assert Enum.count(response) == 1
      assert [event] = response

      # must be listing the event belonging to the current user
      assert event["id"] == e.id

      assert [%{
        "talks" => talks,
        "sponsors" => sponsors,
        "speakers" => speakers,
        "user" => resp_user
      }] = response

      # check the user OMT
      assert resp_user["id"] == e.user_id && resp_user["id"] == user.id

      assert is_list(talks)
      assert Enum.count(talks) == 3
      assert is_list(sponsors)
      assert Enum.count(sponsors) == 2
      assert is_list(speakers)
      assert Enum.count(speakers) == 3
    end

    @tag individual_test: "events_index", login_as: "email@email.com"
    test "renders an empty array of events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert json_response(conn, 200)
      response = json_response(conn, 200)["data"]
      assert [] == response
    end

    # CREATE
    @tag individual_test: "events_create", login_as: "email@email.com"
    test "renders created event when data is valid", %{conn: conn, user: user} do
      attrs = Map.put_new(@create_attrs, :user_id, user.id)
      conn = post(conn, Routes.event_path(conn, :create), event: attrs)
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

    @tag individual_test: "events_create", login_as: "email@email.com"
    test "renders create errors when data is invalid", %{conn: conn, user: user} do
      attrs = Map.put_new(@invalid_attrs, :user_id, user.id)

      conn = post(conn, Routes.event_path(conn, :create), event: attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    # UPDATE
    @tag individual_test: "events_update", login_as: "email@email.com"
    test "renders updated event when data is valid", %{conn: conn, user: user} do
      event = insert(:event, %{user: user})
      id = event.id
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

    @tag individual_test: "events_update", login_as: "email@email.com"
    test "renders update errors when data is invalid", %{conn: conn, user: user} do
      event = insert(:event, %{user: user})
      conn = put(conn, Routes.event_path(conn, :update, event), event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "events_update", login_as: "email@email.com"
    test "renders update errors when event is inexistent", %{conn: conn} do
      conn = put(conn, Routes.event_path(conn, :update, "666"), event: @update_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "events_update", login_as: "email@email.com"
    test "renders update errors when the event belongs to another user", %{conn: conn, evil_event: evil_event} do
      conn = put(conn, Routes.event_path(conn, :update, evil_event.id), event: @update_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    # DELETE
    @tag individual_test: "events_delete", login_as: "email@email.com"
    test "deletes chosen event", %{conn: conn, user: user} do
      event = insert(:event, %{user: user})
      conn = delete(conn, Routes.event_path(conn, :delete, event))
      assert response(conn, 204)

      #conn = get(conn, Routes.event_path(conn, :show, event))
      #assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    @tag individual_test: "events_delete", login_as: "email@email.com"
    test "renders 404 for delete non existent event", %{conn: conn} do
      conn = delete(conn, Routes.event_path(conn, :delete, -1))
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    @tag individual_test: "events_delete_", login_as: "email@email.com"
    test "renders 404 for delete an event which belongs to another user", %{conn: conn, evil_event: evil_event} do
      conn = delete(conn, Routes.event_path(conn, :delete, evil_event.id))
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  # SHOW
  describe "with an event" do
    setup %{conn: conn} do
      event = insert(:event)
      {:ok, conn: conn, event: event}
    end

    @tag individual_test: "events_show"
    test "404 for get an event by id", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_path(conn, :show, -1))

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    @tag individual_test: "events_show"
    test "get an event by id", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      assert event = json_response(conn, 200)["data"]
    end

    @tag individual_test: "events_show"
    # can get an event without JWT - in the "future" we should use domain check logic
    test "get an event by id without authentication", %{conn: conn, event: event} do
      response =
        conn
        |> delete_req_header("authorization")
        |> get(Routes.event_path(conn, :show, event.id))
        |> json_response(200)

      assert event = response
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, Routes.event_path(conn, :index)),
      put(conn, Routes.event_path(conn, :update, "123", %{})),
      post(conn, Routes.event_path(conn, :create, %{})),
      delete(conn, Routes.event_path(conn, :delete, "123")),
    ], fn conn ->
      assert json_response(conn, 401)["message"] == "unauthenticated"
    end)
  end
end
