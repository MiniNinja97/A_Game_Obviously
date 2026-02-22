defmodule MyApp.Game.State do
  @moduledoc """
  Represents the entire game state.

  This struct is the single source of truth for:
  - Player data
  - Current room
  - Current phase
  - Log events
  """

  defstruct [
    :player,
    :room,
    :phase,
    :location,
    road_visits: 0,
    pending_items: [],
    log: []
  ]

  @type player :: %{
          name: String.t(),
          health: integer(),
          attack: integer(),
          intellect: integer(),
          inventory: list(),
          gold: integer()
        }

  @type t :: %__MODULE__{
          player: player() | nil,
          room: map() | nil,
          phase: atom(),
          location: atom() | nil,
          road_visits: integer(),
          pending_items: list(),
          log: list(map())
        }

  @doc """
  Creates a new initial game state.
  Starts in :character_creation phase.
  """
  def new do
    %__MODULE__{
      player: nil,
      room: nil,
      phase: :character_creation,
      location: nil,
      road_visits: 0,
      pending_items: [],
      log: [
        %{type: :log, text: "Oh well before you can even play this game we have to go through some stuff you and I."},
        %{type: :log, text: "Whenever you see a '->' click enter or press continue."},
        %{type: :log, text: "Sometimes I'll give you commands you can write."},
        %{type: :log, text: "Oh and you obviously need a name for your character."},
        %{type: :log, text: "Choose something silly like you people always do ->"}
      ]
    }
  end
end
