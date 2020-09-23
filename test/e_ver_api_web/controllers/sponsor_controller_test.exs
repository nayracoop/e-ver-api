defmodule EVerApiWeb.SponsorControllerTest do
  use EVerApiWeb.ConnCase

  alias EVerApi.Ever
  alias EVerApi.Ever.Sponsor

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
    {:ok, sponsor} = Ever.create_sponsor(@create_attrs)
    sponsor
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all sponsors", %{conn: conn} do
      conn = get(conn, Routes.sponsor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create sponsor" do
    test "renders sponsor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.sponsor_path(conn, :create), sponsor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.sponsor_path(conn, :show, id))

      assert %{
               "id" => id,
               "logo" => "some logo",
               "name" => "some name",
               "website" => "some website"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.sponsor_path(conn, :create), sponsor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update sponsor" do
    setup [:create_sponsor]

    test "renders sponsor when data is valid", %{conn: conn, sponsor: %Sponsor{id: id} = sponsor} do
      conn = put(conn, Routes.sponsor_path(conn, :update, sponsor), sponsor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.sponsor_path(conn, :show, id))

      assert %{
               "id" => id,
               "logo" => "some updated logo",
               "name" => "some updated name",
               "website" => "some updated website"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, sponsor: sponsor} do
      conn = put(conn, Routes.sponsor_path(conn, :update, sponsor), sponsor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete sponsor" do
    setup [:create_sponsor]

    test "deletes chosen sponsor", %{conn: conn, sponsor: sponsor} do
      conn = delete(conn, Routes.sponsor_path(conn, :delete, sponsor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.sponsor_path(conn, :show, sponsor))
      end
    end
  end

  defp create_sponsor(_) do
    sponsor = fixture(:sponsor)
    %{sponsor: sponsor}
  end
end
