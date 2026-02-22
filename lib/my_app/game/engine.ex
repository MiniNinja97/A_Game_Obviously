defmodule MyApp.Game.Engine do
  alias MyApp.Game.{State, Intro, Road, Room, Combat, Loot}

  @spec new_game() :: State.t()
  def new_game do
    State.new()
  end

  @spec handle_input(State.t(), String.t()) :: State.t()
  def handle_input(%State{phase: :character_creation} = state, input) do
    {new_state, events} = Intro.handle(state, input)
    updated_logs = state.log ++ events
    %{new_state | log: updated_logs}
  end

  def handle_input(state, input) do
    {new_state, events} =
      case state.phase do
        :road -> Road.handle(state, input)
        :room -> Room.handle(state, input)
        :combat -> Combat.handle(state, input)
        :loot -> Loot.handle(state, input)
        :game_over -> {state, [%{type: :log, text: "Game Over."}]}
      end

    updated_logs = state.log ++ events
    %{new_state | log: updated_logs}
  end
end
