defmodule EVerApiWeb.ControllerHelper do
  @moduledoc """
  common functions for controllers
  """

  @doc """
  If a user is logued-in fetch user id from conn.
  If the resource doesn't require authentication returns nil

  ## Examples

      iex> extract_user(conn)
      1

      iex> extract_user(conn)
      nil
  """
  def extract_user(conn) do
    # using Guardian data for user id retrieving
    case conn.private[:guardian_default_resource] do
      nil -> nil
      user -> user.id
    end
  end
end
