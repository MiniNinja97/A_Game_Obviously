

defmodule MyApp.Game.Intro do
  alias MyApp.Game.State
  alias MyApp.Game

  @spec handle(State.t(), String.t(), map()) :: {State.t(), list(map())}
  def handle(%State{phase: :character_creation} = state, name, game_round) do
    clean_name = String.trim(name)

    if clean_name == "" do
      {state, [%{type: :log, text: "Come on mate.... even goblins have names. Try again ->"}]}
    else
      player = %{
        name: clean_name,
        health: 100,
        attack: 10,
        intellect: 5,
        inventory: [],
        gold: 10
      }

      new_state = %State{state | player: player, phase: :road, location: :road}

      # Spara namnet direkt i databasen
      Game.update_game(game_round, %{character_name: clean_name})

      events = [
        %{type: :log, text: "Nice. #{clean_name} it is. ->"},
        %{type: :log, text: "Let the suffering begin. ->"},
        %{type: :log, text: "You find yourself standing on a lonely road."},
        %{type: :log, text: "Type 'move' to walk forward."}
      ]

      {new_state, events}
    end
  end
end
