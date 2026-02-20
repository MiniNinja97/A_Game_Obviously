defmodule MyApp.Game.ItemGenerator do
  @moduledoc """
  Responsible for generating items in the game.
  """

  alias MyApp.Game.Dice

  @items [
    %{name: "Apple", type: :health, value: 20},
    %{name: "Bread", type: :health, value: 15},
    %{name: "Wooden Stick", type: :attack, value: 5},
    %{name: "Iron Sword", type: :attack, value: 15},
    %{name: "Rotten Apple", type: :health, value: -10},
    %{name: "Bread with Worms", type: :health, value: -15},
    %{name: "Coriander Surprise", type: :attack, value: -5}
  ]

  @doc """
  Returns a random list of items based on dice roll.
  """
  def generate_items do
    amount = Dice.roll(3) - 1
    Enum.take_random(@items, amount)
  end
end
