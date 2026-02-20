defmodule MyApp.Game.Intro do
  @moduledoc """
  Handles the intro phase of the game.
  """

  alias MyApp.Game.State

  @intro_texts [
    "Du vaknar upp, yr och lite lätt förvirrad.",
    "Var är du?",
    "Det enda du har framför dig är en lång, enslig väg.",
    "Ja… det enda du kan göra nu är väl att börja gå.",
    "",
    "Skriv 'move' för att börja gå."
  ]

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :intro} = state, "move") do
    events =
      Enum.map(@intro_texts, fn text ->
        %{type: :log, text: text}
      end)

    new_state = %State{
      state
      | phase: :road,
        location: :road
    }

    {new_state, events}
  end

  def handle(%State{} = state, _command) do
    {state, [%{type: :log, text: "Skriv 'move' för att börja ditt äventyr."}]}
  end
end
