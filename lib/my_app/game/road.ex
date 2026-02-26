defmodule MyApp.Game.Road do
  alias MyApp.Game.{State, Room}

  @road_texts [
    "You feel the wind on your face.",
    "A raven caws in the distance.",
    "You step on a loose stone.",
    "You hear something rattling in the bushes."
  ]

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :road} = state, command) do
    cmd = String.trim(command) |> String.downcase()

    cond do
      cmd == "move" ->
        handle_move(state)

      cmd == "inventory" ->
        show_inventory(state)

      true ->
        {state,
         [%{type: :log, text: "Huh whut? If you wanna move forward you have to write 'move' or 'inventory'"}]}
    end
  end

  # =====================
  # MOVE LOGIC
  # =====================
  defp handle_move(state) do
    case state.road_visits do
      0 ->
        text = Enum.random(@road_texts)

        new_state = %State{
          state
          | road_visits: 1
        }

        {new_state, [%{type: :log, text: text}]}

      1 ->
        room = Room.random_room()

        new_state = %State{
          state
          | phase: :room,
            location: :room,
            room: room,
            road_visits: 0
        }

        {
          new_state,
          [
            %{type: :log, text: "A new place emerges from afar: #{room.name}"},
            %{type: :log, text: room.description},
            %{
              type: :log,
              text:
                "You can: 'go straight forward', 'go left', 'go right', 'search', or 'inventory'."
            }
          ]
        }
    end
  end

  # =====================
  # INVENTORY LOGIC
  # =====================
  defp show_inventory(state) do
    inventory = state.player.inventory || []

    if inventory == [] do
      {state, [%{type: :log, text: "Your inventory is empty. You only have 10 gold."}]}
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
