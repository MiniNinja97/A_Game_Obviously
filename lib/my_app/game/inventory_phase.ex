defmodule MyApp.Game.InventoryPhase do
  alias MyApp.Game.State
  alias MyApp.Game.Inventory

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :inventory} = state, command) do
    case String.split(String.downcase(command)) do
      ["use", num] -> use_item(state, String.to_integer(num) - 1)
      ["leave", num] -> leave_item(state, String.to_integer(num) - 1)
      _ -> {state, [%{type: :log, text: "Try: use 1 / leave 1"}]}
    end
  end

  defp use_item(state, index) do
    case Enum.at(state.player.inventory, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

      item ->
        {player, effect_logs} =
          case item do
            %{type: type, value: value} ->
              updated_player =
                case type do
                  :health -> Map.update!(state.player, :health, &(&1 + value))
                  :attack -> Map.update!(state.player, :attack, &(&1 + value))
                end

              {updated_player, [%{type: :log, text: "You used #{item.name}."}]}
          end

        # Ta bort item från inventory
        new_inventory = List.delete_at(state.player.inventory, index)
        player = %{player | inventory: new_inventory}

        new_state = %{state | player: player}

        {new_state, effect_logs}
    end
  end

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
end
