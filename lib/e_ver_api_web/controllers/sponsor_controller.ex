defmodule EVerApiWeb.SponsorController do
  use EVerApiWeb, :controller

  alias EVerApi.Sponsors
  alias EVerApi.Sponsors.Sponsor

  action_fallback EVerApiWeb.FallbackController

  # def index(conn, _params) do
  #   sponsors = Sponsors.list_sponsors()
  #   render(conn, "index.json", sponsors: sponsors)
  # end

  def create(conn, %{"sponsor" => sponsor_params}) do
    with {:ok, %Sponsor{} = sponsor} <- Sponsors.create_sponsor(sponsor_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.sponsor_path(conn, :show, sponsor))
      |> render("show.json", sponsor: sponsor)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   sponsor = Sponsors.get_sponsor!(id)
  #   render(conn, "show.json", sponsor: sponsor)
  # end

  def update(conn, %{"id" => id, "sponsor" => sponsor_params}) do
    sponsor = Sponsors.get_sponsor!(id)

    with {:ok, %Sponsor{} = sponsor} <- Sponsors.update_sponsor(sponsor, sponsor_params) do
      render(conn, "show.json", sponsor: sponsor)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsor = Sponsors.get_sponsor!(id)

    with {:ok, %Sponsor{}} <- Sponsors.delete_sponsor(sponsor) do
      send_resp(conn, :no_content, "")
    end
  end
end
