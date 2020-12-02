defmodule EVerApi.SponsorsTest do
  use EVerApi.DataCase

  alias EVerApi.Sponsors

  describe "sponsors" do
    alias EVerApi.Sponsors.Sponsor
    setup do
      e = insert(:event)
      %{event: e}
    end
    @valid_attrs %{logo: "some logo", name: "some name", website: "some website"}
    @update_attrs %{logo: "some updated logo", name: "some updated name", website: "some updated website"}
    @invalid_attrs %{logo: nil, name: nil, website: nil}

    def sponsor_fixture(attrs \\ %{}) do
      {:ok, sponsor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sponsors.create_sponsor()

      sponsor
    end

    @tag individual_test: "list_sponsors"
    test "list_sponsors/0 returns all sponsors", %{event: event} do
      sponsor = sponsor_fixture(%{event_id: event.id})
      # should not list undeleted
      sponsor_del = sponsor_fixture(%{event_id: event.id, name: "neike"})
      Sponsors.delete_sponsor(sponsor_del)
      # 2 sponsors were defined in factory
      sponsors = Sponsors.list_sponsors()
      assert is_list(sponsors)
      assert Enum.count(sponsors) == 3
      # look for added sponsor
      sp = Enum.find(sponsors, fn s -> s.id == sponsor.id end)

      assert nil != sp
      assert %{
        logo: "some logo",
        name: "some name",
        website: "some website"
        } = sp
      assert event.id == sp.event_id
    end

    @tag individual_test: "list_sponsors"
    test "list_sponsors/0 returns empty list if there is no sponsors", %{event: event} do
      assert Sponsors.list_sponsors()
    end

    @tag individual_test: "get_sponsor"
    test "get_sponsor!/1 returns the sponsor with given id", %{event: event} do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert Sponsors.get_sponsor!(sponsor.id) == sponsor
    end

    @tag individual_test: "get_sponsor"
    test "get_sponsor/1 returns the sponsor with given id", %{event: event} do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert Sponsors.get_sponsor(sponsor.id) == sponsor
      assert Sponsors.get_sponsor("666") == nil
    end
    # CREATE
    @tag individual_test: "create_sponsor"
    test "create_sponsor/1 with valid data creates a sponsor", %{event: event} do
      assert {:ok, %Sponsor{} = sponsor} = Sponsors.create_sponsor(Map.put(@valid_attrs, :event_id, event.id))
      assert sponsor.logo == "some logo"
      assert sponsor.name == "some name"
      assert sponsor.website == "some website"
    end

    @tag individual_test: "create_sponsor"
    test "create_sponsor/1 with invalid data returns error changeset", %{event: event} do
      assert {:error, %Ecto.Changeset{}} = Sponsors.create_sponsor(Map.put(@invalid_attrs, :event_id, event.id))
    end

    @tag individual_test: "create_sponsor"
    test "create_sponsor/1 with an inexistent event data returns error changeset", %{event: event} do
      assert {:error, %Ecto.Changeset{}} = Sponsors.create_sponsor(Map.put(@valid_attrs, :event_id, "666"))
    end

    # UPDATE
    @tag individual_test: "update_sponsor"
    test "update_sponsor/2 with valid data updates the sponsor", %{event: event}  do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert {:ok, %Sponsor{} = sponsor} = Sponsors.update_sponsor(sponsor, @update_attrs)
      assert sponsor.logo == "some updated logo"
      assert sponsor.name == "some updated name"
      assert sponsor.website == "some updated website"
    end

    @tag individual_test: "update_sponsor"
    test "update_sponsor/2 with invalid data returns error changeset", %{event: event}  do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert {:error, %Ecto.Changeset{}} = Sponsors.update_sponsor(sponsor, @invalid_attrs)
      assert sponsor == Sponsors.get_sponsor!(sponsor.id)
    end

    @tag individual_test: "update_sponsor"
    test "update_sponsor/2 with an inexisten event returns error changeset", %{event: event}  do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert {:error, %Ecto.Changeset{}} = Sponsors.update_sponsor(sponsor, Map.put(@valid_attrs, :event_id, "666"))
    end

    # DELETE
    @tag individual_test: "delete_sponsor"
    test "delete_sponsor/1 deletes the sponsor", %{event: event} do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert {:ok, %Sponsor{}} = Sponsors.delete_sponsor(sponsor)
      assert nil == Sponsors.get_sponsor(sponsor.id)
      # EXPERIMENTAL get_sponsor!/1 retrieves deleted
      #assert %{...} = Ever.get_sponsor!(sponsor.id)
    end

    @tag individual_test: "change_sponsor"
    test "change_sponsor/1 returns a sponsor changeset", %{event: event} do
      sponsor = sponsor_fixture(%{event_id: event.id})
      assert %Ecto.Changeset{} = Sponsors.change_sponsor(sponsor)
    end
  end

end
