defmodule EVerApiWeb.SpeakerControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Speaker

  @create_attrs %{
    avatar: "some avatar",
    bio: "some bio",
    company: "some company",
    first_name: "some first_name",
    last_name: "some last_name",
    name: "some name",
    role: "some role"
  }
  @update_attrs %{
    avatar: "some updated avatar",
    bio: "some updated bio",
    company: "some updated company",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    name: "some updated name",
    role: "some updated role"
  }
  @invalid_attrs %{avatar: nil, bio: nil, company: nil, first_name: nil, last_name: nil, name: nil, role: nil}

  def fixture(:speaker) do
    {:ok, speaker} = Ever.create_speaker(@create_attrs)
    speaker
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all speakers", %{conn: conn} do
      conn = get(conn, Routes.speaker_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create speaker" do
    test "renders speaker when data is valid", %{conn: conn} do
      conn = post(conn, Routes.speaker_path(conn, :create), speaker: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.speaker_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar" => "some avatar",
               "bio" => "some bio",
               "company" => "some company",
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "name" => "some name",
               "role" => "some role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.speaker_path(conn, :create), speaker: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update speaker" do
    setup [:create_speaker]

    test "renders speaker when data is valid", %{conn: conn, speaker: %Speaker{id: id} = speaker} do
      conn = put(conn, Routes.speaker_path(conn, :update, speaker), speaker: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.speaker_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar" => "some updated avatar",
               "bio" => "some updated bio",
               "company" => "some updated company",
               "first_name" => "some updated first_name",
               "last_name" => "some updated last_name",
               "name" => "some updated name",
               "role" => "some updated role"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, speaker: speaker} do
      conn = put(conn, Routes.speaker_path(conn, :update, speaker), speaker: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete speaker" do
    setup [:create_speaker]

    test "deletes chosen speaker", %{conn: conn, speaker: speaker} do
      conn = delete(conn, Routes.speaker_path(conn, :delete, speaker))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.speaker_path(conn, :show, speaker))
      end
    end
  end

  defp create_speaker(_) do
    speaker = fixture(:speaker)
    %{speaker: speaker}
  end
end
