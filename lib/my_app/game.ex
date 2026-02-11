defmodule MyApp.Game do
  import Ecto.Query
  alias MyApp.Repo
  alias MyApp.Game.GameRound

  # hämta pågående spel
  def get_ongoing_game(user_id) do
    Repo.one(
      from g in GameRound,
     where: g.user_id == ^user_id and g.status == "ongoing"
    )
  end

  # starta eller resume ett game

  def start_or_resume_game(user_id, character_name) do
    case get_ongoing_game(user_id ) do
      nil ->
        %GameRound{}
        |>GameRound.changeset(%{
          user_id: user_id,
          character_name: character_name,
          started_at: DateTime.utc_now(),
          status: "ongoing"
        })
        |> Repo.insert()

        game ->
          {:ok, game}
    end
  end

  # uppdatera/spara spel

  def update_game(game_round, attrs) do
    game_round
    |> GameRound.changeset(attrs)
    |> Repo.update()
  end

  # avsluta spel
  def finish_game(game_round) do
    update_game(game_round, %{
      status: "finished",
    ended_at: DateTime.utc_now()
    })
  end

  # scoreboard
  def list_finished_games(user_id) do
    Repo.all(
      from g in GameRound,
      where: g.user_id == ^user_id and g.status == "finished",
      order_by: [desc: g.finished_at]
    )
  end


end
