# defmodule MyApp.Game.Intro do
#   @moduledoc """
#   Handles the intro phase of the game.
#   """

#   alias MyApp.Game.State

#   @intro_texts [
#     "Du vaknar upp, yr och lite lätt förvirrad.",
#     "Var är du?",
#     "Det enda du har framför dig är en lång, enslig väg.",
#     "Ja… det enda du kan göra nu är väl att börja gå.",
#     "",
#     "Skriv 'move' för att börja gå."
#   ]

#   @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
#   def handle(%State{phase: :intro} = state, "move") do
#     events =
#       Enum.map(@intro_texts, fn text ->
#         %{type: :log, text: text}
#       end)

#     new_state = %State{
#       state
#       | phase: :road,
#         location: :road
#     }

#     {new_state, events}
#   end

#   def handle(%State{} = state, _command) do
#     {state, [%{type: :log, text: "Skriv 'move' för att börja ditt äventyr."}]}
#   end
# end

defmodule MyApp.Game.Intro do
  @moduledoc """
  Handles the intro phase of the game, where the player wakes up and starts their journey.
  """

alias MyApp.Game.State

@spec handle(State.t(), String.t()) :: {State.t(), list(map())}
def handle(%State{phase: :character_creation} = state, name) do
  clean_name = String.trim(name)

#"skydd" så splearen inte kan skriva in ett tomt namn
if clean_name == "" do
  {
    state,
    [%{type: :log, text: "Come on mate.... even goblins have names. Try again ->"}]
  }
else
  #här skapas player
  player = %{
    name: clean_name,
    health: 100,
    attack: 10,
    intellect: 5,
    inventory: [],
    gold: 10
  }

  #uppdatera state
  new_state = %State{
    state |
    player: player,
    phase: :road,
    location: :road
  }

  #log-events som skickas till gameserver
  events = [
        %{type: :log, text: "Nice. #{clean_name} it is."},
        %{type: :log, text: "Let the suffering begin."},
        %{type: :log, text: "You find yourself standing on a lonely road."},
        %{type: :log, text: "Type 'move' to walk forward."}
      ]

      {new_state, events}
end
end
end
