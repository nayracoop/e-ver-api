defmodule EVerApi.SponsorsTest do
  use EVerApi.DataCase

  alias EVerApi.Sponsors

  describe "sponsors" do
    alias EVerApi.Sponsors.Sponsor

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

    test "list_sponsors/0 returns all sponsors" do
      sponsor = sponsor_fixture()
      assert Sponsors.list_sponsors() == [sponsor]
    end

    test "get_sponsor!/1 returns the sponsor with given id" do
      sponsor = sponsor_fixture()
      assert Sponsors.get_sponsor!(sponsor.id) == sponsor
    end

    test "create_sponsor/1 with valid data creates a sponsor" do
      assert {:ok, %Sponsor{} = sponsor} = Sponsors.create_sponsor(@valid_attrs)
      assert sponsor.logo == "some logo"
      assert sponsor.name == "some name"
      assert sponsor.website == "some website"
    end

    test "create_sponsor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sponsors.create_sponsor(@invalid_attrs)
    end

    test "update_sponsor/2 with valid data updates the sponsor" do
      sponsor = sponsor_fixture()
      assert {:ok, %Sponsor{} = sponsor} = Sponsors.update_sponsor(sponsor, @update_attrs)
      assert sponsor.logo == "some updated logo"
      assert sponsor.name == "some updated name"
      assert sponsor.website == "some updated website"
    end

    test "update_sponsor/2 with invalid data returns error changeset" do
      sponsor = sponsor_fixture()
      assert {:error, %Ecto.Changeset{}} = Sponsors.update_sponsor(sponsor, @invalid_attrs)
      assert sponsor == Sponsors.get_sponsor!(sponsor.id)
    end

    test "delete_sponsor/1 deletes the sponsor" do
      sponsor = sponsor_fixture()
      assert {:ok, %Sponsor{}} = Sponsors.delete_sponsor(sponsor)
      assert_raise Ecto.NoResultsError, fn -> Sponsors.get_sponsor!(sponsor.id) end
    end

    test "change_sponsor/1 returns a sponsor changeset" do
      sponsor = sponsor_fixture()
      assert %Ecto.Changeset{} = Sponsors.change_sponsor(sponsor)
    end
  end

end
