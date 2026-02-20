defmodule MyApp.Game.Loot do
  @moduledoc """
  This module handles the logic for loot drops after combat encounters.
  """

  alias MyApp.Game.State


@doc """

Parses player commands related to loot management, such as using an item, storing it, or leaving it behind.
"""
 @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :loot} = state, command) do
    case parse_command(command) do
      {:use, index} ->
        use_item(state, index)

      {:store, index} ->
        store_item(state, index)

      {:leave, _index} ->
        leave_items(state)

      :invalid ->
        {state, [%{type: :log, text: "Try: use 1 / store 1 / leave 1"}]}
    end
  end

  defp parse_command(command) do
    case String.split(String.downcase(command)) do
      ["use", num ] -> {:use, String.to_integer(num) - 1}
      ["store", num] -> {:store, String.to_integer(num) - 1}
      ["leave", num] -> {:leave, String.to_integer(num) - 1}
      _ -> :invalid
    end
  end



  defp use_item(state, index) do
    case Enum.at(state.pending_items, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

        item ->
          player = apply_item_effect(state.player, item)

          new_state = %State{
            state |
            player: player,
            phase: :road,
            pending_items: []
          }
          {new_state, [%{type: :log, text: "You used #{item.name}."}]}

    end
  end

  defp store_item(state, index) do
    case Enum.at(state.pending_items, index) do
      nil ->
        {state, [%{type: :log, text: "Invalid item"}]}

        item ->
          new_inventory = state.player.inventory ++ [item]
          player = %{state.player | inventory: new_inventory}

          new_state = %State{
            state |
            player: player,
            phase: :road,
            pending_items: []
          }
          {new_state, [%{type: :log, text: "You stored #{item.name} in your inventory."}]}

    end
  end

  defp apply_item_effect(player, item) do
    case item.type do
      :health ->
        Map.update!(player, :health, &(&1 + item.value))

      :attack ->
        Map.update!(player, :attack, &(&1 + item.value))

      _ ->
        player
    end
    apply_special_effect(player, item)
  end

  defp apply_special_effect(player, item) do
  case item[:effect] do
    :rotten ->
      if :rand.uniform(2) == 1 do
        Map.update!(player, :health, &(&1 - 5))
      else
        player
      end

    :worm ->
      Map.update!(player, :health, &(&1 - 3))

    :cursed ->
      if :rand.uniform(2) == 1 do
        Map.update!(player, :attack, &(&1 - 5))
      else
        player
      end

    _ ->
      player
  end
end

  defp leave_items(state) do
  new_state = %State{
    state |
    phase: :road,
    pending_items: []
  }

  {new_state, [%{type: :log, text: "You leave the items behind and move on."}]}
end
end
