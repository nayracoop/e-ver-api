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

  # describe "index" do
  #   test "lists all speakers", %{conn: conn} do
  #     conn = get(conn, Routes.speaker_path(conn, :index))
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
    @tag individual_test: "speakers_create", login_as: "email@email.com"
    test "renders speaker when data is valid", %{conn: conn, user: user, event: event} do

      conn = post(conn, Routes.speaker_path(conn, :create, event.id), speaker: @create_attrs)
      response = json_response(conn, 201)["data"]
      assert %{
               "id" => id,
               "avatar" => "some avatar",
               "bio" => "some bio",
               "company" => "some company",
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "name" => "some name",
               "role" => "some role"
             } = response

      # check if event contains the speaker
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      resp = List.last(json_response(conn, 200)["data"]["speakers"])
      assert %{
        "id" => id,
        "avatar" => "some avatar",
        "bio" => "some bio",
        "company" => "some company",
        "first_name" => "some first_name",
        "last_name" => "some last_name",
        "name" => "some name",
        "role" => "some role"
      } = resp
    end

    @tag individual_test: "speakers_create", login_as: "email@email.com"
    test "renders errors when trying to add speaker to non existent event", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.speaker_path(conn, :create, "666"), speaker: @valid_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "speakers_create", login_as: "email@email.com"
    test "renders errors when data is invalid", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.speaker_path(conn, :create, event.id), speaker: @invalid_attrs)
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

  @tag individual_test: "speakers_401"
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      post(conn, Routes.speaker_path(conn, :create, "666", %{})),
      put(conn, Routes.speaker_path(conn, :update, "666", "123", %{})),
      delete(conn, Routes.speaker_path(conn, :delete, "666", "234"))
    ], fn conn ->
      assert json_response(conn, 401)["message"] == "unauthenticated"
    end)
  end
end
