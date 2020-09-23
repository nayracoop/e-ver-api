defmodule EVerApiWeb.SpeakerController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Speaker

  action_fallback EVerApiWeb.FallbackController

  def index(conn, _params) do
    speakers = Ever.list_speakers()
    render(conn, "index.json", speakers: speakers)
  end

  def create(conn, %{"speaker" => speaker_params}) do
    with {:ok, %Speaker{} = speaker} <- Ever.create_speaker(speaker_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.speaker_path(conn, :show, speaker))
      |> render("show.json", speaker: speaker)
    end
  end

  def show(conn, %{"id" => id}) do
    speaker = Ever.get_speaker!(id)
    render(conn, "show.json", speaker: speaker)
  end

  def update(conn, %{"id" => id, "speaker" => speaker_params}) do
    speaker = Ever.get_speaker!(id)

    with {:ok, %Speaker{} = speaker} <- Ever.update_speaker(speaker, speaker_params) do
      render(conn, "show.json", speaker: speaker)
    end
  end

  def delete(conn, %{"id" => id}) do
    speaker = Ever.get_speaker!(id)

    with {:ok, %Speaker{}} <- Ever.delete_speaker(speaker) do
      send_resp(conn, :no_content, "")
    end
  end
end
