defmodule EVerApiWeb.SponsorControllerTest do
  use EVerApiWeb.ConnCase, async: true
  @moduletag :sponsors_controller_case

  alias EVerApi.Sponsors
  alias EVerApi.Sponsors.Sponsor
  alias EVerApi.Ever.Event

  @create_attrs %{
    logo: "some logo",
    name: "some name",
    website: "some website"
  }
  @update_attrs %{
    logo: "some updated logo",
    name: "some updated name",
    website: "some updated website"
  }
  @invalid_attrs %{logo: nil, name: nil, website: nil}

  def fixture(:sponsor) do
    {:ok, sponsor} = Sponsors.create_sponsor(@create_attrs)
    sponsor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "with a logged-in user" do
    setup %{conn: conn, login_as: email} do
      user = insert(:user, email: email)
      event = insert(:event, %{user: user})

      # other user and event
      evil_user = insert(:user, %{first_name: "Mauricio", email: "666@999.pro"})

      evil_event =
        insert(:event, %{
          name: "in some places there is plenty of water and in others there is no",
          user: evil_user
        })

      {:ok, jwt_string, _} = EVerApi.Accounts.token_sign_in(email, "123456")

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt_string}")

      {:ok, conn: conn, user: user, event: event, evil_user: evil_user, evil_event: evil_event}
    end

    # CREATE SPONSOR
    @tag individual_test: "sponsors_create", login_as: "email@email.com"
    test "renders sponsor when data is valid", %{conn: conn, user: user, event: event} do
      conn = post(conn, Routes.sponsor_path(conn, :create, event.id), sponsor: @create_attrs)

      assert %{
               "id" => sponsor_id,
               "logo" => "some logo",
               "name" => "some name",
               "website" => "some website"
             } = json_response(conn, 201)["data"]

      # fetch the event and check
      conn = get(conn, Routes.event_path(conn, :show, event.id))
      assert response = json_response(conn, 200)["data"]

      # event response
      %{"sponsors" => sponsors, "user" => resp_user} = response

      assert resp_user["id"] == user.id
      assert Enum.count(sponsors) == 3
      sp = Enum.find(sponsors, fn x -> x["id"] == sponsor_id end)

      assert %{
               "id" => ^sponsor_id,
               "logo" => "some logo",
               "name" => "some name",
               "website" => "some website"
             } = sp
    end

    @tag individual_test: "sponsors_create", login_as: "email@email.com"
    test "renders errors when trying to add a sponsor to non existent event", %{conn: conn} do
      conn = post(conn, Routes.sponsor_path(conn, :create, "666"), sponsor: @create_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_create", login_as: "email@email.com"
    test "renders errors when data is invalid", %{conn: conn, event: %Event{id: event_id}} do
      conn = post(conn, Routes.sponsor_path(conn, :create, event_id), sponsor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "sponsors_create", login_as: "email@email.com"
    test "renders 404 when trying to create a sponsor for an event which belongs to another user",
         %{conn: conn, evil_event: %Event{id: evil_event_id}} do
      conn = post(conn, Routes.sponsor_path(conn, :create, evil_event_id), sponsor: @create_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end

    # UPDATE
    @tag individual_test: "sponsors_update", login_as: "email@email.com"
    test "renders sponsor when update data is valid", %{conn: conn, user: user, event: event} do
      %Sponsor{id: sponsor_id} = List.first(event.sponsors)

      conn =
        put(conn, Routes.sponsor_path(conn, :update, event.id, sponsor_id), sponsor: @update_attrs)

      assert %{
               "id" => id,
               "logo" => "some updated logo",
               "name" => "some updated name",
               "website" => "some updated website"
             } = json_response(conn, 200)["data"]

      assert id == sponsor_id

      # fetch event and check updated speaker
      conn = get(conn, Routes.event_path(conn, :show, event.id))

      %{"sponsors" => sponsors, "user" => resp_user} = json_response(conn, 200)["data"]
      # check user
      assert resp_user["id"] == user.id
      # check the updated sponsor
      sp = Enum.find(sponsors, fn x -> x["id"] == id end)

      assert %{
               "id" => ^sponsor_id,
               "logo" => "some updated logo",
               "name" => "some updated name",
               "website" => "some updated website"
             } = sp
    end

    @tag individual_test: "sponsors_update", login_as: "email@email.com"
    test "render errors when trying to update a sponsor to a non existent event", %{
      conn: conn,
      event: event
    } do
      %Sponsor{id: sponsor_id} = List.first(event.sponsors)

      conn =
        put(conn, Routes.sponsor_path(conn, :update, "666", sponsor_id), sponsor: @update_attrs)

      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_update", login_as: "email@email.com"
    test "render errors when trying to update a non  existen sponsor to a valid event", %{
      conn: conn,
      event: event
    } do
      conn =
        put(conn, Routes.sponsor_path(conn, :update, event.id, "666"), sponsor: @update_attrs)

      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_update", login_as: "email@email.com"
    test "renders errors when update data is invalid", %{conn: conn, event: event} do
      %Sponsor{id: sponsor_id} = List.first(event.sponsors)

      conn =
        put(conn, Routes.sponsor_path(conn, :update, event.id, sponsor_id),
          sponsor: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    @tag individual_test: "sponsors_update", login_as: "email@email.com"
    test "render 404 when trying to update a sponsor in event which belongs to another user", %{
      conn: conn,
      evil_event: evil_event
    } do
      %Sponsor{id: sponsor_id} = List.first(evil_event.sponsors)

      conn =
        put(conn, Routes.sponsor_path(conn, :update, evil_event.id, sponsor_id),
          sponsor: @update_attrs
        )

      assert json_response(conn, 404)["errors"] != %{}
    end

    # DELETE
    @tag individual_test: "sponsors_delete_", login_as: "email@email.com"
    test "deletes chosen sponsor", %{conn: conn, user: user, event: event} do
      %Sponsor{id: sponsor_id} = List.first(event.sponsors)

      conn = delete(conn, Routes.sponsor_path(conn, :delete, event.id, sponsor_id))
      assert response(conn, 204)
      assert Sponsors.get_sponsor(sponsor_id) == nil

      # Check the event no longer contains the sponsor
      conn = get(conn, Routes.event_path(conn, :show, event.id))

      %{"sponsors" => sponsors, "user" => resp_user} = json_response(conn, 200)["data"]
      # check user
      assert resp_user["id"] == user.id

      sp = Enum.find(sponsors, fn x -> x["id"] == sponsor_id end)
      assert sp == nil

      # trying to re delete :(
      conn = delete(conn, Routes.sponsor_path(conn, :delete, event.id, sponsor_id))
      assert response(conn, 404)
    end

    @tag individual_test: "sponsors_delete", login_as: "email@email.com"
    test "renders errors when trying to delete a sponsor to non existent event", %{
      conn: conn,
      event: event
    } do
      %Sponsor{id: sponsor_id} = List.first(event.sponsors)
      conn = delete(conn, Routes.sponsor_path(conn, :delete, "666", sponsor_id))
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_delete", login_as: "email@email.com"
    test "renders errors when trying to delete non existent sponsor for a valid event", %{
      conn: conn,
      event: %Event{id: event_id, sponsors: sponsors}
    } do
      %Sponsor{} = List.first(sponsors)
      conn = delete(conn, Routes.sponsor_path(conn, :delete, event_id, "666"))
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_delete", login_as: "email@email.com"
    test "renders errors when trying to delete a sponsor which belongs to another event", %{
      conn: conn,
      event: event
    } do
      e = insert(:event, %{name: "foreign event"})
      s = insert(:sponsor, %{event_id: e.id})
      conn = delete(conn, Routes.sponsor_path(conn, :delete, event.id, s.id))
      assert json_response(conn, 404)["errors"] != %{}
    end

    @tag individual_test: "sponsors_delete_", login_as: "email@email.com"
    test "renders 404 when trying to delete a sponsor in event which belongs to another user", %{
      conn: conn,
      evil_event: evil_event
    } do
      %Sponsor{id: sponsor_id} = List.first(evil_event.sponsors)
      conn = delete(conn, Routes.sponsor_path(conn, :delete, evil_event.id, sponsor_id))
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  # 401 Unauthorized
  @tag individual_test: "sponsors_401"
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        post(conn, Routes.sponsor_path(conn, :create, "666", %{})),
        put(conn, Routes.sponsor_path(conn, :update, "666", "123", %{})),
        delete(conn, Routes.sponsor_path(conn, :delete, "666", "234"))
      ],
      fn conn ->
        assert json_response(conn, 401)["message"] == "unauthenticated"
      end
    )
  end
end
