defmodule MyApp.Game.Map do
  @moduledoc """
  Generates random rooms and enemies.
  """

  alias MyApp.Game.Character

  def generate_room do
    %{
      name: random_room_name(),
      enemy: random_enemy(),
      items: []
    }
  end

  defp random_room_name do
    [
      "Dark Cave",
      "Abandoned Dungeon",
      "Haunted Forest",
      "Ancient Ruins"
    ]
    |> Enum.random()
  end

  defp random_enemy do
    [
      Character.make_living("Goblin", 50, 10),
      Character.make_living("Orc", 80, 15),
      Character.make_living("Troll", 120, 20)
    ]
    |> Enum.random()
  end
end
