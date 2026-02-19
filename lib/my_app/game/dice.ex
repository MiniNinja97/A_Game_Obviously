defmodule MyApp.Game.Dice do
  @moduledoc """
  Slumptärning för combat, loot, etc.
  """

  @spec roll(integer()) :: integer()
  def roll(sides \\ 6) do
    :rand.uniform(sides)
  end
end
