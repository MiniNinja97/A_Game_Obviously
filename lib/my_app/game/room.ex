defmodule MyApp.Game.Room do
  alias MyApp.Game.State
  alias MyApp.Game.ItemGenerator

  @moduledoc """
  This module handles the logic for the "room" phase of the game.
  """




  @room_names [
    "Dark Cave",
    "Abandoned Dungeon",
    "Haunted Forest",
    "Ancient Ruins"
  ]

  # ROOM GENERATION

  @doc """
  Generates a random room with an enemy and some items.
  """
  def random_room do
    %{
      name: Enum.random(@room_names),
      enemy: %{name: "Goblin", health: 50, attack: 10},
      items: ItemGenerator.generate_items(),
      description: "Du kliver in i ett rum. Det luktar fukt och mögel."
    }
  end

  # COMMAND HANDLING

  @doc """
  Parses player commands related to room navigation and searching.
  """
  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :room} = state, command) do
    case command do
      "go straight forward" ->
        {
          %{state | phase: :combat},
          [%{type: :log, text: "You see an enemy! Prepare for battle!"}]
        }

      "go left" ->
        {
          %{state | phase: :game_over},
          [
            %{
              type: :log,
              text: "Woops, clumsy dimwit! Yoy just fell dow a huge whole and died! Game Over! :D"
            }
          ]
        }

      "go right" ->
        trigger_loot(state)

      "search" ->
        trigger_loot(state)

      "inventory" ->
        show_inventory(state)

      _ ->
        {
          state,
          [
            %{
              type: :log,
              text: "Uhm whut?. Try 'go straight forward', 'go left', 'go right', or 'search'."
            }
          ]
        }
    end
  end


  # LOOT TRIGGER

  defp trigger_loot(state) do
    items = state.room.items || []

    if items == [] do
      {
        state,
        [%{type: :log, text: "The room is empty. Nothing to loot."}]
      }
    else
      events =
        Enum.with_index(items, 1)
        |> Enum.map(fn {item, i} ->
          %{type: :log, text: "#{i}. #{item.name} (#{item.type}: +#{item.value})"}
        end)

      new_state = %State{
        state
        | phase: :loot,
          pending_items: items
      }

      {new_state, events}
    end
  end

  defp show_inventory(state) do
  inventory = state.player.inventory || []

  if inventory == [] do
    {state, [%{type: :log, text: "Your inventory is empty."}]}
  else
    events =
      inventory
      |> Enum.with_index(1)
      |> Enum.map(fn {item, i} ->
        %{type: :log, text: "#{i}. #{item.name} (#{item.type}: #{item.value})"}
      end)

    {state, events}
  end
end
end
