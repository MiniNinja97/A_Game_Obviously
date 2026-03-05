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
    :previous_phase,
    :location,
    :game_round,
    road_visits: 0,
    rooms_visited: 0,
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
          game_round: map() | nil,
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
        %{type: :log, text: "Hi there stranger!"},
        %{type: :log, text: "I have been waiting for you"},
        %{type: :log, text: "For qite some time actually..."},
        %{type: :log, text: "Anyways let's get to the point, I have a game for you to play."},
        %{type: :log, text: "Oh well before you can even play this game we have to go through some stuff you and I."},
        %{type: :log, text: "Whenever you see a '->' press continue. ->"},
         %{type: :log, text: "Sometimes I'll give you commands you can write."},
         %{type: :log, text: "So there two types of comunication on your end, either you write a command or you press continue when you see '->'."},
        %{type: :log, text: "I suggest you pay attention then and use these commands, otherwise this is gonna be a very long and boring game ->"},
        %{type: :log, text: "Oh and you obviously need a name before we can start. ->"},
        %{type: :log, text: "You know famous people, heroes and even villians. Hell everyone goes under an alias nowadays. So what name do you want to go by?"},
        %{type: :log, text: "Choose something silly like you people always do"},
        %{type: :log, text: "Go on then I don't have all day, write that bloody name of yours"},
        %{type: :log, text: "And then press continue, yea yea ->"}
      ]
    }
  end
end
