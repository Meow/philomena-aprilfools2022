defmodule PhilomenaWeb.EventPartyPooperPlug do
  alias Philomena.Badges.Badge
  alias Philomena.Badges.Award
  alias Philomena.Repo
  import Ecto.Query

  def init([]), do: []

  def call(conn, _opts) do
    maybe_destroy_badge_award(conn)
  end

  defp maybe_destroy_badge_award(%{assigns: %{current_user: %{role: "user", id: user_id}}, cookies: %{"fucknfts" => "true"}} = conn) do
    badge = Repo.get_by(limit(Badge, 1), title: "Non-Fungible Booru")

    if not is_nil(badge) do
      award = Repo.get_by(limit(Award, 1), badge_id: badge.id, user_id: user_id)

      if not is_nil(award) do
        Repo.delete(award)
      end
    end

    conn
  end

  defp maybe_destroy_badge_award(conn), do: conn
end
