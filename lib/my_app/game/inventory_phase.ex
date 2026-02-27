defmodule MyApp.Game.InventoryPhase do
  alias MyApp.Game.{State, Inventory}

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :inventory} = state, command) do
    case String.split(String.downcase(command)) do
      ["use", num] ->
        {new_state, logs} = use_item(state, String.to_integer(num) - 1)
        continue_phase_after_inventory(new_state, logs)

      ["store", num] ->
        {new_state, logs} = store_item(state, String.to_integer(num) - 1)
        continue_phase_after_inventory(new_state, logs)

      ["leave", num] ->
        {new_state, logs} = leave_item(state, String.to_integer(num) - 1)
        continue_phase_after_inventory(new_state, logs)

      ["exit"] ->
        {
          %{state | phase: state.previous_phase, previous_phase: nil},
          [%{type: :log, text: "Closing inventory..."}]
        }

      _ ->
        {state, [%{type: :log, text: "Try: use 1 / store 1 / leave 1 / exit"}]}
    end
  end

  # =====================
  # Continue phase after inventory
  # =====================
  defp continue_phase_after_inventory(state, logs) do
    next_phase =
      cond do
        Map.get(state, :pending_items, []) != [] -> :loot
        Map.has_key?(state, :previous_phase) && state.previous_phase != nil -> state.previous_phase
        true -> :road
      end

    {%{state | phase: next_phase, previous_phase: (if next_phase == :loot, do: state.previous_phase, else: nil)}, logs}
  end

  # =====================
  # Use item
  # =====================
  defp use_item(state, index) do
    case Enum.at(state.player.inventory, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

      item ->
        player =
          case item.type do
            :health -> Map.update!(state.player, :health, &(&1 + item.value))
            :attack -> Map.update!(state.player, :attack, &(&1 + item.value))
          end

        new_inventory = List.delete_at(state.player.inventory, index)
        player = %{player | inventory: new_inventory}
        new_state = %{state | player: player}

        {new_state, [%{type: :log, text: "You used #{item.name}."}]}
    end
  end

  # =====================
  # Leave item
  # =====================
  defp leave_item(state, index) do
    case Enum.at(state.player.inventory, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

      item ->
        new_inventory = List.delete_at(state.player.inventory, index)
        player = %{state.player | inventory: new_inventory}
        new_state = %{state | player: player}

        {new_state, [%{type: :log, text: "You left #{item.name} behind."}]}
    end
  end

  # =====================
  # Store item
  # =====================
  defp store_item(state, index) do
    case Enum.at(state.player.inventory, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

      item ->
        if Inventory.full?(state.player.inventory) do
          {state, [%{type: :log, text: "Your inventory is full, cannot store #{item.name}."}]}
        else
          {:ok, new_inventory} = Inventory.add(state.player.inventory, item)
          player = %{state.player | inventory: new_inventory}

          # Ta bort från pending_items om det finns
          pending_items =
            if Map.has_key?(state, :pending_items) do
              List.delete_at(state.pending_items || [], index)
            else
              state.pending_items || []
            end

          new_state = %{state | player: player, pending_items: pending_items}

          {new_state, [%{type: :log, text: "You stored #{item.name} in your inventory."}]}
        end
    end
  end
end
