defmodule EVerApiWeb.SpeakerController do
  use EVerApiWeb, :controller

  alias EVerApi.Ever
  alias EVerApi.Ever.Speaker

  action_fallback EVerApiWeb.FallbackController

  # def index(conn, _params) do
  #   speakers = Ever.list_speakers()
  #   render(conn, "index.json", speakers: speakers)
  # end

  def create(conn, %{"event_id" => event_id, "speaker" => speaker_params}) do
    # Next time use Ecto relationship and update event

    case Ever.get_event(event_id) do
      nil ->  {:error, :not_found}
      event ->
        params = Map.put_new(speaker_params, "event_id", event.id)
        with {:ok, %Speaker{} = speaker} <- Ever.create_speaker(params) do
          conn
          |> put_status(:created)
          |> render("show.json", speaker: speaker)
        end
    end
  end

  # def show(conn, %{"id" => id}) do
  #   speaker = Ever.get_speaker!(id)
  #   render(conn, "show.json", speaker: speaker)
  # end

  def update(conn, %{"event_id" => event_id, "id" => id, "speaker" => speaker_params}) do

    case Ever.get_event(event_id) do
      nil ->  {:error, :not_found}
      event ->
        with speaker when not is_nil(speaker) <- Ever.get_speaker(id),
        true <- is_valid_speaker(speaker, event.id),
        {:ok, %Speaker{} = speaker}  <- Ever.update_speaker(speaker, speaker_params) do
          render(conn, "show.json", speaker: speaker)
        else
          {:error,  %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}  # speaker not found
        end
    end
  end

  def delete(conn, %{"event_id" => event_id, "id" => id}) do
    case Ever.get_event(event_id) do
      nil ->  {:error, :not_found}
      event ->
        with speaker when not is_nil(speaker) <- Ever.get_speaker(id),
        true <- is_valid_speaker(speaker, event.id),
        {:ok, %Speaker{}} <- Ever.delete_speaker(speaker) do
          send_resp(conn, :no_content, "")
        else
          {:error,  %Ecto.Changeset{} = changeset} -> {:error, changeset}
          _ -> {:error, :not_found}  # speaker not found
        end
      end
  end

  defp is_valid_speaker(speaker, event_id) do
    speaker.event_id == event_id
  end
end
