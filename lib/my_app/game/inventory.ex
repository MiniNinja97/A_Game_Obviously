defmodule MyApp.Game.Inventory do


  @max_size 4

  def full?(inventory), do: length(inventory) >= @max_size

  def add(inventory, item), do: inventory ++ [item]

  def swap(inventory, index, new_item), do: List.replace_at(inventory, index, new_item)
end
