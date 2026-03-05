defmodule MyApp.Game.Engine do
  alias MyApp.Game.{State, Intro, Road, Room, Combat, Loot, InventoryPhase, Tavern}

  @spec new_game() :: State.t()
  def new_game do
    State.new()
  end

  # =========================
  # Hantera input från spelaren
  # =========================
  # Tar nu emot game_round som tredje argument
  @spec handle_input(State.t(), String.t(), any()) :: {State.t(), list(map())}
  def handle_input(%State{phase: :character_creation} = state, input, game_round) do
    # Trimma och ta bort extra citattecken
    clean_input = String.trim(input) |> String.replace(~r/^"|"$/, "")

    # Kalla på Intro.handle/3 som uppdaterar game_round direkt
    Intro.handle(state, clean_input, game_round)
  end

  def handle_input(state, input, _game_round) do
    clean_input = String.trim(input) |> String.replace(~r/^"|"$/, "")

    {new_state, events} =
      case state.phase do
        :road -> Road.handle(state, clean_input)
        :room -> Room.handle(state, clean_input)
        :combat -> Combat.handle(state, clean_input)
        :loot -> Loot.handle(state, clean_input)
        :tavern -> Tavern.handle(state, input)
        :tavern_bar -> Tavern.handle(state, input)
        :inventory -> InventoryPhase.handle(state, clean_input)
        :game_over -> {state, [%{type: :log, text: "Game Over."}]}
      end

    {new_state, events}
  end
end
