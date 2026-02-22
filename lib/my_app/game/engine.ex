defmodule MyApp.Game.Engine do
  @moduledoc """
  Central game engine that routes all player input to the correct handler
  depending on the current game phase.
  """

  alias MyApp.Game.{State, Intro, Road, Room}

  @doc """
  Starts a new game. Returns initial state.
  """
  @spec new_game() :: State.t()
  def new_game do
    State.new()
  end

  @doc """
  Handles player input.
  Routes to the correct module depending on phase.

  Returns `{new_state, events}`.
  """
  @spec handle_input(State.t(), String.t()) :: {State.t(), list(map())}
  def handle_input(%State{} = state, input) do
    input = String.trim(input)

    case state.phase do
      :character_creation ->
        # Intro hanterar namnval
        Intro.handle(state, input)

      :road ->
        Road.handle(state, input)

      :room ->
        Room.handle(state, input)

      _ ->
        # fallback om phase inte matchar
        {
          state,
          [%{type: :log, text: "Unknown phase: #{inspect(state.phase)}"}]
        }
    end
  end
end
