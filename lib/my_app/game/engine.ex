defmodule MyApp.Game.Engine do
  @moduledoc """
  Main game orchestrator.
  Delegates commands based on current game phase.
  """

  alias MyApp.Game.{State, Road, Room, Combat, Intro, Loot}

  @doc """
  Creates a new game state for a user.
  """
  @spec new_game(String.t()) :: State.t()
  def new_game(player_name) do
    State.new(player_name)
  end

  @doc """
  Handles player input and routes it depending on phase.
  Returns updated state.
  """
  @spec handle_input(State.t(), String.t()) :: State.t()
  def handle_input(state, input) do
    {new_state, events} =
      case state.phase do
        :intro -> Intro.handle(state, input)
        :road -> Road.handle(state, input)
        :room -> Room.handle(state, input)
        :combat -> Combat.handle(state, input)
        :loot -> Loot.handle(state, input)
        :game_over -> {state, [%{type: :log, text: "Game Over."}]}
      end

    # Append logs
    updated_logs = state.log ++ events

    %{new_state | log: updated_logs}
  end
end
