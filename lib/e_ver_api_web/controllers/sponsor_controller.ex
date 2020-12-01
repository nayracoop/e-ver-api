defmodule EVerApiWeb.SponsorController do
  use EVerApiWeb, :controller

  alias EVerApi.Sponsors
  alias EVerApi.Sponsors.Sponsor
  alias EVerApi.Ever

  action_fallback EVerApiWeb.FallbackController

  # def index(conn, _params) do
  #   sponsors = Sponsors.list_sponsors()
  #   render(conn, "index.json", sponsors: sponsors)
  # end

  def create(conn, %{"event_id" => event_id, "sponsor" => sponsor_params}) do

    case Ever.get_event(event_id) do
      nil -> {:error, :not_found}
      event ->
        params = Map.put_new(sponsor_params, "event_id", event.id)
        with {:ok, %Sponsor{} = sponsor} <- Sponsors.create_sponsor(params) do

          conn
          |> put_status(:created)
          |> render("show.json", sponsor: sponsor)
        end
    end
  end

  # def show(conn, %{"id" => id}) do
  #   sponsor = Sponsors.get_sponsor!(id)
  #   render(conn, "show.json", sponsor: sponsor)
  # end

  def update(conn, %{"event_id" => event_id, "id" => id, "sponsor" => sponsor_params}) do
    case Ever.get_event(event_id) do
      nil -> {:error, :not_found}
      event ->
        with sponsor when not is_nil(sponsor) <- Sponsors.get_sponsor(id),
        true <- is_valid_sponsor(sponsor, event.id),
        {:ok, %Sponsor{} = sponsor} <- Sponsors.update_sponsor(sponsor, sponsor_params) do
          render(conn, "show.json", sponsor: sponsor)
        else
          {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}
        end
    end
  end

  def delete(conn, %{"event_id" => event_id, "id" => id}) do
    case Ever.get_event(event_id) do
      nil -> {:error, :not_found}
      event ->
        with sponsor when not is_nil(sponsor) <- Sponsors.get_sponsor(id),
        true <- is_valid_sponsor(sponsor, event.id),
        {:ok, %Sponsor{}} <- Sponsors.delete_sponsor(sponsor) do
          send_resp(conn, :no_content, "")
        else
          {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}
        end
    end


    # sponsor = Sponsors.get_sponsor!(id)

    # with {:ok, %Sponsor{}} <- Sponsors.delete_sponsor(sponsor) do
    #   send_resp(conn, :no_content, "")
    # end
  end

  defp is_valid_sponsor(sponsor, event_id) do
    sponsor.event_id == event_id
  end
end
