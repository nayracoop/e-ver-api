defmodule EVerApi.Ever do
  @moduledoc """
  The Ever context.
  """

  import Ecto.Query, warn: false
  alias EVerApi.Repo

  alias EVerApi.Accounts.User
  alias EVerApi.Ever.{Event, Talk}
  import Ecto.SoftDelete.Query

  defp filter_user(query, nil), do: query
  defp filter_user(query, id), do: where(query, user_id: ^id)

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(user_id \\ nil) do
    query = from(e in Event, select: e)
      |> filter_user(user_id) # check the user owns the events
      |> with_undeleted()
    Repo.all(query) |> Repo.preload([:user, :sponsors, :speakers, {:talks, :speakers}])
  end

  def list_events_no_preload do
    from(e in Event, select: e)
    |> with_undeleted()
    |> Repo.all
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do
    query = from(e in Event, select: e)
      |> with_undeleted()
    Repo.get!(query, id) |> Repo.preload([:user, :sponsors, :speakers, {:talks, :speakers}])
  end

  @doc """
  Gets a single event.

  returns nil if the Event does not exist.

  ## Examples

      iex> get_event(123)
      %Event{}

      iex> get_event(456)
      nil

  """
  def get_event(id, user_id \\ nil) do
    # filter soft-deleted associations
    speakers_query = from(s in EVerApi.Ever.Speaker, select: s)
      |> with_undeleted()

    talks_query = from(t in EVerApi.Ever.Talk, select: t)
      |> with_undeleted() |> preload(:speakers)

    sponsors_query = from(sp in EVerApi.Sponsors.Sponsor, select: sp)
      |> with_undeleted()

    query = from(e in Event, select: e)
      |> filter_user(user_id)
      |> with_undeleted()

    Repo.get(query, id)
      |> Repo.preload([:user, [sponsors: sponsors_query], [speakers: speakers_query], [talks: talks_query]])
  end



  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def create_event(attrs, %User{} = user) do
    %Event{}
    |> Event.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.soft_delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  alias EVerApi.Ever.Talk

  @doc """
  Returns the list of talks.

  ## Examples

      iex> list_talks()
      [%Talk{}, ...]

  """
  def list_talks do
    query = from(t in Talk, select: t)
      |> with_undeleted()

      # filter soft-deleted associations
    speakers_query = from(s in EVerApi.Ever.Speaker, select: s)
      |> with_undeleted()

    Repo.all(query) |> Repo.preload([speakers: speakers_query])
  end

  @doc """
  Gets a single talk.

  Raises `Ecto.NoResultsError` if the Talk does not exist.

  ## Examples

      iex> get_talk!(123)
      %Talk{}

      iex> get_talk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_talk!(id) do
    # filter soft-deleted associations
    speakers_query = from(s in EVerApi.Ever.Speaker, select: s)
      |> with_undeleted()
    # intentionaly not using soft delete for evaluating its usage en this function
    Repo.get!(Talk, id) |> Repo.preload([speakers: speakers_query])
  end

  @doc """
  Gets a single talk.

  Returns nil if the Talk does not exist.

  ## Examples

      iex> get_talk!(123)
      %Talk{}

      iex> get_talk!(456)
      nil

  """
  def get_talk(id) do
    # filter soft-deleted associations
    speakers_query = from(s in EVerApi.Ever.Speaker, select: s)
      |> with_undeleted()
    query = from(t in Talk, select: t) |> with_undeleted()
    Repo.get(query, id) |> Repo.preload([speakers: speakers_query])
  end

  @doc """
  Creates a talk.

  ## Examples

      iex> create_talk(%{field: value})
      {:ok, %Talk{}}

      iex> create_talk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_talk(attrs \\ %{}) do
    %Talk{}
    |> Talk.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a talk.

  ## Examples

      iex> update_talk(talk, %{field: new_value})
      {:ok, %Talk{}}

      iex> update_talk(talk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_talk(%Talk{} = talk, attrs) do
    talk
    |> Talk.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a talk.

  ## Examples

      iex> delete_talk(talk)
      {:ok, %Talk{}}

      iex> delete_talk(talk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_talk(%Talk{} = talk) do
    Repo.soft_delete(talk)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking talk changes.

  ## Examples

      iex> change_talk(talk)
      %Ecto.Changeset{data: %Talk{}}

  """
  def change_talk(%Talk{} = talk, attrs \\ %{}) do
    Talk.changeset(talk, attrs)
  end

  alias EVerApi.Ever.Speaker

  @doc """
  Returns the list of speakers.

  ## Examples

      iex> list_speakers()
      [%Speaker{}, ...]

  """
  def list_speakers do
    query = from(s in Speaker, select: s)
      |> with_undeleted()
    Repo.all(query)
  end

  @doc """
  Gets a single speaker.

  Raises `Ecto.NoResultsError` if the Speaker does not exist.

  ## Examples

      iex> get_speaker!(123)
      %Speaker{}

      iex> get_speaker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_speaker!(id) do
    query = from(s in Speaker, select: s)
      |> with_undeleted()
    Repo.get!(query, id)
  end

  @doc """
  Gets a single speaker.

  Returns nil if the Speaker does not exist.

  ## Examples

      iex> get_speaker(123)
      %Speaker{}

      iex> get_speaker(456)
      nil

  """
  def get_speaker(id) do
    query = from(s in Speaker, select: s)
      |> with_undeleted()
    Repo.get(query, id)
  end
  @doc """
  Creates a speaker.

  ## Examples

      iex> create_speaker(%{field: value})
      {:ok, %Speaker{}}

      iex> create_speaker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_speaker(attrs \\ %{}) do
    %Speaker{}
    |> Speaker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a speaker.

  ## Examples

      iex> update_speaker(speaker, %{field: new_value})
      {:ok, %Speaker{}}

      iex> update_speaker(speaker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_speaker(%Speaker{} = speaker, attrs) do
    speaker
    |> Speaker.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a speaker.

  ## Examples

      iex> delete_speaker(speaker)
      {:ok, %Speaker{}}

      iex> delete_speaker(speaker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_speaker(%Speaker{} = speaker) do
    Repo.soft_delete(speaker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking speaker changes.

  ## Examples

      iex> change_speaker(speaker)
      %Ecto.Changeset{data: %Speaker{}}

  """
  def change_speaker(%Speaker{} = speaker, attrs \\ %{}) do
    Speaker.changeset(speaker, attrs)
  end

  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end
end
