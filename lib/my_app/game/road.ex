defmodule MyApp.Game.Road do
  alias MyApp.Game.{State, Room, Tavern}

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
      new_state = %State{state | road_visits: 1}
      {new_state, [%{type: :log, text: text}]}

    1 ->
      if state.rooms_visited >= 2 do
        # Skicka till tavernan
        Tavern.enter(state)
      else
        room = Room.random_room()
        new_state = %State{
          state
          | phase: :room,
            location: :room,
            room: room,
            road_visits: 0
        }

        {new_state, [
          %{type: :log, text: "A new place emerges from afar: #{room.name}"},
          %{type: :log, text: room.description},
          %{type: :log, text: "You can: 'go straight forward', 'go left', 'go right', 'search', or 'inventory'."}
        ]}
      end
  end
end

  # =====================
  # INVENTORY LOGIC
  # =====================
  defp show_inventory(state) do
  inventory = state.player.inventory || []

  if inventory == [] do
    {state, [%{type: :log, text: "Your inventory is empty."}]}
  else
    item_logs =
      Enum.with_index(inventory, 1)
      |> Enum.map(fn {item, i} ->
        %{type: :log, text: "#{i}. #{item.name} (#{item.type}: #{item.value})"}
      end)

    action_log = %{type: :log, text: "Type: use 1 / store 1 / leave 1 / exit"}

    new_state = %State{
      state |
      previous_phase: state.phase,
      phase: :inventory
    }

    {new_state, item_logs ++ [action_log]}
  end
end
end
