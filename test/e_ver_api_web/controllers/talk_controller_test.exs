defmodule EVerApiWeb.TalkControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk

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
    start_time: "2010-04-1T14:00:00Z",
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

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.talk_path(conn, :create), talk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update talk" do
    setup [:create_talk]

    test "renders talk when data is valid", %{conn: conn, talk: %Talk{id: id} = talk} do
      conn = put(conn, Routes.talk_path(conn, :update, talk), talk: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.talk_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some updated body",
               "duration" => 43,
               "name" => "some updated name",
               "start_time" => "2011-05-18T15:01:01Z",
               "tags" => [],
               "video_url" => "some updated video_url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, talk: talk} do
      conn = put(conn, Routes.talk_path(conn, :update, talk), talk: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete talk" do
    setup [:create_talk]

    test "deletes chosen talk", %{conn: conn, talk: talk} do
      conn = delete(conn, Routes.talk_path(conn, :delete, talk))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.talk_path(conn, :show, talk))
      end
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
