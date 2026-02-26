defmodule MyApp.Game.Inventory do
  @moduledoc """
  Handles inventory logic such as adding, removing and checking size.
  """

  @max_size 4

  @doc """
  Returns true if inventory is full.
  """
  def full?(inventory) do
    length(inventory) >= @max_size
  end

  @doc """
  Adds an item to inventory if there is space.
  Returns:
    {:ok, updated_inventory}
    {:error, :full}
  """
  def add(inventory, item) do
    if full?(inventory) do
      {:error, :full}
    else
      {:ok, inventory ++ [item]}
    end
  end

  @doc """
  Removes an item by index.
  Returns:
    {:ok, updated_inventory}
    {:error, :invalid_index}
  """
  def remove(inventory, index) do
    case Enum.at(inventory, index) do
      nil ->
        {:error, :invalid_index}

      _item ->
        {:ok, List.delete_at(inventory, index)}
    end
  end

  @doc """
  Replaces an item at a given index.
  """
  def swap(inventory, index, new_item) do
    List.replace_at(inventory, index, new_item)
  end
end
