defmodule MyApp.Game.Character do

  @doc """
  Represents both the player and enemies, with attributes like health, attack power, and inventory.
  """
  def make_living(name, health, attack) do
    %{
      name: name,
      health: health,
      attack: attack,
      inventory: []
    }
  end
end
