defmodule EVerApiWeb.TalkControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk

  @moduletag :talks_controller_case

  @create_attrs %{
    title: "some title",
    details: "some details",
    summary: "some summary",
    start_time: "2010-04-17T14:00:00Z",
    duration: 42,
    tags: ["elsa", "raquel"],
    allow_comments: true,
    video: %{uri: "some video_uri", type: "video", autoplay: false}
  }
  @update_attrs %{
    title: "some updated title",
    details: "some updated details",
    summary: "some updated summary",
    start_time: "2010-04-17T14:00:00Z",
    duration: 42,
    tags: ["elsa", "pablito"],
    allow_comments: true,
    video: %{uri: "some updated video_uri", type: "live video", autoplay: true}
  }
  @invalid_attrs %{title: nil, duration: nil, summary: nil, start_time: nil, tags: nil, video_url: nil}

  def fixture(:talk) do
    {:ok, talk} = Ever.create_talk(@create_attrs)
    talk
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # describe "index" do
  #   test "lists all talks", %{conn: conn} do
  #     conn = get(conn, Routes.talk_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  describe "with a logged-in user" do
    setup %{conn: conn, login_as: email} do
      user = insert(:user, email: email)
      event = insert(:event, %{user: user})
      {:ok, jwt_string, _} = EVerApi.Accounts.token_sign_in(email, "123456")

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt_string}")

      {:ok, conn: conn, user: user, event: event}
    end

    # CREATE
    @tag individual_test: "talks_create", login_as: "email@email.com"
    test "renders talk when data is valid", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.talk_path(conn, :create, event.id), talk: @create_attrs)
      assert  %{
          "id" => id,
          "title" => "some title",
          "details" => "some details",
          "summary" => "some summary",
          "start_time" => "2010-04-17T14:00:00Z",
          "duration" => 42,
          "tags" => ["elsa", "raquel"],
          "allow_comments" => true,
          "video" => %{"uri" => "some video_uri", "type" => "video", "autoplay" => false},
          "speakers" => []
        } = json_response(conn, 201)["data"]

      # check if the event has the talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      resp = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == id end)
      assert  %{
        "id" => id,
        "title" => "some title",
        "details" => "some details",
        "summary" => "some summary",
        "start_time" => "2010-04-17T14:00:00Z",
        "duration" => 42,
        "tags" => ["elsa", "raquel"],
        "allow_comments" => true,
        "video" => %{"uri" => "some video_uri", "type" => "video", "autoplay" => false},
        "speakers" => []
      } = resp
    end

    @tag individual_test: "talks_create", login_as: "email@email.com"
    test "renders errors when trying to add a talk to non existent event", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.talk_path(conn, :create, "666"), talk: @create_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "talks_create", login_as: "email@email.com"
    test "renders errors when data is invalid", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.talk_path(conn, :create, event.id), talk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    # CREATE with associated speakers
    @tag individual_test: "talks_create_add_speaker", login_as: "email@email.com"
    test "create a talk with speakers then renders talk when data is valid", %{conn: conn, user: user, event: event} do
      s1 = insert(:speaker, %{event_id: event.id})
      s2 = insert(:speaker, %{event_id: event.id})

      # create other event to test if the speaker is being added by error in the former test event
      other_event = insert(:event)
      s3 = insert(:speaker, %{event_id: other_event.id})

      # try to add 2 valid speakers - 1 inexistent speaker - a foreign speaker
      conn = post(conn, Routes.talk_path(conn, :create, event.id), talk: Map.put(@create_attrs, :speakers, [s1.id, s2.id, s3.id, 666]))

      response = json_response(conn, 201)["data"]
      assert  %{
          "id" => talk_id,
          "title" => "some title",
          "details" => "some details",
          "summary" => "some summary",
          "start_time" => "2010-04-17T14:00:00Z",
          "duration" => 42,
          "tags" => ["elsa", "raquel"],
          "allow_comments" => true,
          "video" => %{"uri" => "some video_uri", "type" => "video", "autoplay" => false},
          "speakers" => speakers
        } = response
      #assert %Ever.Speaker{} = s_.id

      assert is_list(speakers)
      assert Enum.count(speakers) == 2
      assert Enum.find(speakers, fn x -> x["id"] == s1.id end)
      assert Enum.find(speakers, fn x -> x["id"] == s2.id end)


      # TODO test helper
      # assert match_view(:speaker, List.first(speaker))

      # check if the event has the talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      resp = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert  %{
        "id" => id,
        "title" => "some title",
        "details" => "some details",
        "summary" => "some summary",
        "start_time" => "2010-04-17T14:00:00Z",
        "duration" => 42,
        "tags" => ["elsa", "raquel"],
        "allow_comments" => true,
        "video" => %{"uri" => "some video_uri", "type" => "video", "autoplay" => false},
        "speakers" => speakers
      } = resp

      assert is_list(speakers)
      assert Enum.count(speakers) == 2
      assert Enum.find(speakers, fn x -> x["id"] == s1.id end)
      assert Enum.find(speakers, fn x -> x["id"] == s2.id end)
    end

    @tag individual_test: "talks_create_add_speaker", login_as: "email@email.com"
    test "renders an error speaker is not a number", %{conn: conn, user: user, event: event} do
      s1 = insert(:speaker, %{event_id: event.id})

      # try to add 2 valid speakers - 1 inexistent speaker - a foreign speaker
      conn = post(conn, Routes.talk_path(conn, :create, event.id), talk: Map.put(@create_attrs, :speakers, [s1.id, "fake"]))
      assert json_response(conn, 422)["errors"] != %{}
    end

    # UPDATE
    @tag individual_test: "talks_update", login_as: "email@email.com"
    test "renders an updated talk when data is valid", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)
      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: @update_attrs)

      assert %{
        "id" => id,
        "title" => "some updated title",
        "details" => "some updated details",
        "summary" => "some updated summary",
        "start_time" => "2010-04-17T14:00:00Z",
        "duration" => 42,
        "tags" => ["elsa", "pablito"],
        "allow_comments" => true,
        "video" => %{"uri" => "some updated video_uri", "type" => "live video", "autoplay" => true}
      } = json_response(conn, 200)["data"]
      assert id == talk_id

      # fetch event and check updated talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      resp = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert %{
        "id" => id,
        "title" => "some updated title",
        "details" => "some updated details",
        "summary" => "some updated summary",
        "start_time" => "2010-04-17T14:00:00Z",
        "duration" => 42,
        "tags" => ["elsa", "pablito"],
        "allow_comments" => true,
        "video" => %{"uri" => "some updated video_uri", "type" => "live video", "autoplay" => true}
      } = resp
    end

    @tag individual_test: "talks_update", login_as: "email@email.com"
    test "renders errors when update data is invalid",  %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)
      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "talks_update", login_as: "email@email.com"
    test "renders errors when trying to update a talk to non existent event", %{conn: conn, user: user, event: event} do
      conn = put(conn, Routes.talk_path(conn, :update, "666", "999"), talk: @update_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "talks_update", login_as: "email@email.com"
    test "renders errors when trying to update non existent talk for a valid event", %{conn: conn, user: user, event: event} do
      conn = put(conn, Routes.talk_path(conn, :update, event.id, "999"), talk: @update_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    # UPDATE with associated speakers
    @tag individual_test: "talks_update_speaker_", login_as: "email@email.com"
    test "updates a list of speakers in a talk adding one", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id, speakers: talk_speakers} = List.first(event.talks)
      [s1, s2] = Enum.map(talk_speakers, fn s -> s.id end)
      %Ever.Speaker{id: s3} = insert(:speaker, %{event_id: event.id})
      # create other event to test if the speaker is being added by error in the former test event
      other_event = insert(:event)
      %Ever.Speaker{id: s4} = insert(:speaker, %{event_id: other_event.id})

      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: %{speakers: [s1, s2, 666, s3, s4]})
      # check the update response view
      assert data = json_response(conn, 200)["data"]
      assert Enum.count(data["speakers"]) == 3
      # compare the ids with the talk response
      Enum.each([s1, s2, s3], fn s ->
        assert Enum.find(data["speakers"], fn x -> x["id"] == s end)
      end)

      # fetch event and check updated talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      talk = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert Enum.count(talk["speakers"]) == 3
      # compare the ids with the event talk
      Enum.each([s1, s2, s3], fn s ->
        assert Enum.find(talk["speakers"], fn x -> x["id"] == s end)
      end)
    end

    @tag individual_test: "talks_update_speaker", login_as: "email@email.com"
    test "updates a list of speakers in a talk removing one of them", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id, speakers: talk_speakers} = List.first(event.talks)
      [s1, s2] = Enum.map(talk_speakers, fn s -> s.id end)
      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: %{speakers: [s1]})
      # check the update response view
      assert data = json_response(conn, 200)["data"]
      assert Enum.count(data["speakers"]) == 1
      s = List.first(data["speakers"])
      assert s["id"] == s1

      # fetch event and check updated talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      talk = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert Enum.count(talk["speakers"]) == 1
      assert List.first(talk["speakers"])["id"] == s1
    end

    @tag individual_test: "talks_update_speaker", login_as: "email@email.com"
    test "updates a list of speakers in a talk removing ALL of them", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id, speakers: talk_speakers} = List.first(event.talks)

      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: %{speakers: []})
      # check the update response view
      assert data = json_response(conn, 200)["data"]
      assert data["speakers"] == []

      # fetch event and check updated talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      talk = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert talk["speakers"] == []
    end

    @tag individual_test: "talks_update_speaker", login_as: "email@email.com"
    test "renders an error speaker is not a number when updating talk", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)
      s1 = insert(:speaker, %{event_id: event.id})

      # try to add 2 valid speakers - 1 inexistent speaker - a foreign speaker
      conn = put(conn, Routes.talk_path(conn, :update, event.id, talk_id), talk: Map.put(@update_attrs, :speakers, [s1.id, "fake"]))
      assert json_response(conn, 422)["errors"] != %{}
    end

    # DELETE
    @tag individual_test: "talks_delete", login_as: "email@email.com"
    test "deletes chosen talk", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)

      conn = delete(conn, Routes.talk_path(conn, :delete, event.id, talk_id))
      assert response(conn, 204)
      assert Ever.get_talk(talk_id) == nil

      # check the event is not rendering the deleted talk
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      resp = Enum.find(json_response(conn, 200)["data"]["talks"], fn x -> x["id"] == talk_id end)
      assert resp == nil

      # trying to re delete :(
      conn = delete(conn, Routes.talk_path(conn, :delete, event.id, talk_id))
      assert response(conn, 404)
    end

    @tag individual_test: "talks_delete", login_as: "email@email.com"
    test "renders errors when trying to delete a talk to non existent event", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)
      conn = delete(conn, Routes.talk_path(conn, :delete, "666", talk_id))
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "talks_delete", login_as: "email@email.com"
    test "renders errors when trying to delete non existent talk for a valid event", %{conn: conn, user: user, event: event} do
      %Talk{id: talk_id} = List.first(event.talks)
      conn = delete(conn, Routes.talk_path(conn, :delete, event.id, "666"))
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "talks_delete", login_as: "email@email.com"
    test "renders errors when trying to delete a talk which belongs to another event", %{conn: conn, user: user, event: event} do
      e = insert(:event, %{name: "foreign event"})
      t = insert(:talk, %{event_id: e.id})
      conn = delete(conn, Routes.talk_path(conn, :delete, event.id, t.id))
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  # 401 Unauthorized
  @tag individual_test: "talks_401"
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      post(conn, Routes.talk_path(conn, :create, "666", %{})),
      put(conn, Routes.talk_path(conn, :update, "666", "123", %{})),
      delete(conn, Routes.talk_path(conn, :delete, "666", "234"))
    ], fn conn ->
      assert json_response(conn, 401)["message"] == "unauthenticated"
    end)
  end

  defp create_talk(_) do
    talk = fixture(:talk)
    %{talk: talk}
  end
end
