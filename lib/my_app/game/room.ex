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

  @spec random_room() :: %{
          description: String.t(),
          enemy: %{attack: integer(), health: integer(), name: String.t()},
          items: list(),
          name: String.t()
        }
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
  Parses player commands related to room navigation, searching, and inventory.
  Works for both :room and :road phases.
  """
  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: phase} = state, command) when phase in [:room, :road] do
    case String.downcase(command) do
      "go straight forward" ->
        {
          %{state | phase: :combat},
          [
            %{type: :log, text: "You see an enemy! Prepare for battle!"},
            %{
              type: :log,
              text:
                "You can 'attack' or 'run'. Pff... running is obviously for pussys, but anyway — what do you want to do?"
            }
          ]
        }

      "go left" ->
        {
          %{state | phase: :game_over},
          [
            %{
              type: :log,
              text: "Woops, clumsy dimwit! You just fell down a huge hole and died! Game Over! :D"
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
              text: "Uhm whut? Try 'go straight forward', 'go left', 'go right', 'search', or 'inventory'."
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

  # SHOW INVENTORY
  defp show_inventory(state) do
    inventory = state.player.inventory || []

    if inventory == [] do
      {state, [%{type: :log, text: "Your inventory is empty."}]}
    else
      # Visa guld först
      gold_items = Enum.filter(inventory, &(&1.type == :gold))
      other_items = Enum.filter(inventory, &(&1.type != :gold))

      events =
        (gold_items ++ other_items)
        |> Enum.with_index(1)
        |> Enum.map(fn {item, i} ->
          "#{i}. #{item.name} (#{item.type}: #{item.value})"
        end)
        |> Enum.map(&%{type: :log, text: &1})

      {state, events}
    end
  end
end
