defmodule PhilomenaWeb.NftController do
  use PhilomenaWeb, :controller

  alias Philomena.Badges.Badge
  alias Philomena.Badges.Award
  alias Philomena.Repo
  import Ecto.Query
  import Bitwise

  def create(%{assigns: %{current_user: %{id: user_id}}} = conn, %{"random_part" => random_part}) do
    {:ok, random_part} = Base.decode16(random_part, case: :mixed)
    hash = :crypto.hash(:sha256, <<user_id::32-little, random_part::binary>>)
    <<first_word::32-big, _rest::binary>> = hash

    case maybe_assign_badge(first_word, user_id) do
      true ->
        conn
        |> put_status(:ok)
        |> json(%{})
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{})
  end

  defp maybe_assign_badge(first_word, user_id) when first_word < (1 <<< (32 - 21)) do
    badge = Repo.get_by(limit(Badge, 1), title: "Non-Fungible Booru")

    if not is_nil(badge) do
      award = Repo.get_by(limit(Award, 1), badge_id: badge.id, user_id: user_id)

      if is_nil(award) do
        %Award{
          badge_id: badge.id,
          user_id: user_id,
          awarded_by_id: user_id,
          awarded_on: DateTime.truncate(DateTime.utc_now(), :second)
        }
        |> Award.changeset(%{})
        |> Repo.insert()

        true
      end
    end
  end

  defp maybe_assign_badge(_first_word, _user_id), do: false
end
