defmodule MyApp.Game.Engine do
  alias MyApp.Game.{State, Intro, Road, Room, Combat, Loot, InventoryPhase}

  @spec new_game() :: State.t()
  def new_game do
    State.new()
  end

  @spec handle_input(State.t(), String.t()) :: {State.t(), list(map())}
  def handle_input(%State{phase: :character_creation} = state, input) do
    # Trimma och ta bort extra citattecken
    clean_input = String.trim(input) |> String.replace(~r/^"|"$/, "")

    # Intro.handle returnerar {new_state, events}
    Intro.handle(state, clean_input)
  end

  def handle_input(state, input) do
    clean_input = String.trim(input) |> String.replace(~r/^"|"$/, "")

    {new_state, events} =
      case state.phase do
        :road -> Road.handle(state, clean_input)
        :room -> Room.handle(state, clean_input)
        :combat -> Combat.handle(state, clean_input)
        :loot -> Loot.handle(state, clean_input)
        :inventory -> InventoryPhase.handle(state, clean_input)
        :game_over -> {state, [%{type: :log, text: "Game Over."}]}
      end

    {new_state, events}
  end
end
