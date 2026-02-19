defmodule MyApp.Game.Room do
  alias MyApp.Game.{State}

  @items [
      %{name: "Apple", type: :health, value: 20},
    %{name: "Bread", type: :health, value: 15},
    %{name: "Wooden Stick", type: :attack, value: 5},
    %{name: "Iron Sword", type: :attack, value: 15}
  ]

  @room_names [
    "Dark Cave",
    "Abandoned Dungeon",
    "Haunted Forest",
    "Ancient Ruins"
  ]

  def random_room do
    %{
      name: Enum.random(@room_names),
      enemy: %{name: "Goblin", health: 50, attack: 10},
      items: Enum.take_random(@items, Enum.random(0..2)),
      description: "Du kliver in i ett rum. Det luktar fukt och mögel."
    }
  end

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :room} = state, command) do
    case command do
      "go straight forward" ->
        {state |> Map.put(:phase, :combat), [%{type: :log, text: "You see an enemy! Prepare for battle!"}]}
        "go left" ->
          {%State{state | phase: :game_over}, [%{type: :log, text: "Woops, clumsy dimwit! Yoy just fell dow a huge whole and died! Game Over! :D"}]}
          "go right" ->
            loot = Enum.random(state.room.items || [])
            msg = if loot, do: "You found a #{loot.name}!", else: "The room is empty. Nothing to loot."
            {state |> Map.put(:phase, :road) |> Map.put(:room, nil), [%{type: :log, text: msg}]}
            "search" ->
              loot = Enum.random(state.room.items || [])
              msg = if loot, do: "You found a #{loot.name}!", else: "You search the room but find nothing."
              {state, [%{type: :log, text: msg}]}
              _ -> {state, [%{type: :log, text: "Uhm whut?. Try 'go straight forward', 'go left', 'go right', or 'search'."}]}


    end
  end
end
