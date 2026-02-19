defmodule MyApp.Game.State do

  @doc """
  Represents the entire game state, including player stats, current room, phase, and log.
   This struct is passed around and updated by the Engine and other modules.
   It serves as the single source of truth for the game's status at any point in time.
   The log field is a list of events that can be rendered in the UI to show what happened.
   The phase field determines which module handles player input and what actions are available.
   The player field contains all relevant information about the player's character, such as health, inventory, etc.
   The room field holds details about the current location or encounter, which can change as the player moves or fights.
  """
  defstruct [
    :player,
    :room,
    :phase,
    :location,
    road_visits: 0,
    log: []
  ]

  @type t :: %__MODULE__{
          player: map(),
          room: map() | nil,
          phase: atom(),
          log: list()
        }

  @doc """
  Creates a new initial game state.
  """
  def new(player_name) do
    %__MODULE__{
      player: %{
        name: player_name,
        health: 100,
        attack: 10,
        inventory: [],
        gold: 10
      },
      room: nil,
      phase: :intro,
      log: [
        %{type: :log, text: "Welcome, #{player_name}."},
        %{type: :log, text: "Type commands to play. Try: 'go', 'search', 'attack'."}
      ]
    }
  end
end
