defmodule EVerApiWeb.TalkControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Talk

  @create_attrs %{
    body: "some body",
    duration: 42,
    name: "some name",
    start_time: "2010-04-17T14:00:00Z",
    tags: [],
    video_url: "some video_url"
  }
  @update_attrs %{
    body: "some updated body",
    duration: 43,
    name: "some updated name",
    start_time: "2011-05-18T15:01:01Z",
    tags: [],
    video_url: "some updated video_url"
  }
  @invalid_attrs %{body: nil, duration: nil, name: nil, start_time: nil, tags: nil, video_url: nil}

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

  describe "create talk" do
    test "renders talk when data is valid", %{conn: conn} do
      conn = post(conn, Routes.talk_path(conn, :create), talk: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.talk_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some body",
               "duration" => 42,
               "name" => "some name",
               "start_time" => "2010-04-17T14:00:00Z",
               "tags" => [],
               "video_url" => "some video_url"
             } = json_response(conn, 200)["data"]
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

  defp create_talk(_) do
    talk = fixture(:talk)
    %{talk: talk}
  end
end
