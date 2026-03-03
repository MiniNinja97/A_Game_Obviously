defmodule MyApp.Game.GameServer do
  use GenServer

  alias MyApp.Game
  alias MyApp.Game.Engine
  alias MyApp.Game.Intro

  # ==========
  # PUBLIC API
  # ==========


  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via(user_id))
  end

  def command(user_id, text) do
    GenServer.cast(via(user_id), {:command, text})
  end

  def set_state(user_id, new_state) do
    GenServer.cast(via(user_id), {:set_state, new_state})
  end

  def get_state(user_id) do
    GenServer.call(via(user_id), :get_state)
  end

  # ==========
  # CALLBACKS
  # ==========

  @impl true
  def init(user_id) do
    {:ok, game_round} = Game.start_or_resume_game(user_id, "Hero")
    initial_state = %{Engine.new_game() | game_round: game_round}

    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{user_id}",
      {:game_events, initial_state.log}
    )

    {:ok,
     %{
       game: initial_state,
       user_id: user_id,
       game_round: game_round
     }}
  end

  @impl true
  def handle_call(:get_state, _from, %{game: game} = state) do
    {:reply, game, state}
  end

  @impl true
  def handle_cast(
        {:command, text},
        %{game: game, user_id: user_id, game_round: game_round} = state
      ) do

    input = String.trim(text)

    {new_game, events} =
      case game.phase do
        :character_creation ->
          Intro.handle(game, input, game_round)

        _ ->
          Engine.handle_input(game, input, game_round)
      end

    # Uppdatera namn efter character creation
    if game.phase == :character_creation and new_game.phase == :road do
      Game.update_game(game_round, %{character_name: new_game.player.name})
    end

    new_state = %{state | game: new_game}

    # Autosave
    autosave(new_state)

    # Om spelaren dött – spara slutstatus
    if new_game.phase == :game_over do
      time_seconds =
        DateTime.diff(DateTime.utc_now(), game_round.started_at, :second)

      final_stats = %{
        health: new_game.player.health,
        gold: new_game.player.gold
      }

      Game.update_game(game_round, %{
        status: "finished",
        finished_at: DateTime.utc_now(),
        time_seconds: time_seconds,
        state: final_stats
      })
    end

    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{user_id}",
      {:game_events, events}
    )

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:set_state, new_state}, state) do
    {:noreply, %{state | game: new_state}}
  end

  # =====================
  # HELPERS
  # =====================

  defp via(user_id), do: {:via, Registry, {MyApp.GameRegistry, user_id}}

  defp autosave(state) do
    Game.update_game(state.game_round, %{
      state: %{
        phase: state.game.phase,
        player: state.game.player,
        location: state.game.location
      }
    })

    state
  end
end
