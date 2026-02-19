defmodule MyApp.Game.Battle do
  alias MyApp.Game.Dice

    @doc """
       Encapsulates combat logic, including attack rolls and damage calculation.
    """

  def battle_round(player, enemy, attacker) do
    roll = Dice.roll(6)

    base_attack =
      case attacker do
        :player -> player.attack
        :enemy -> enemy.attack
      end

    damage = trunc(base_attack * (roll / 10))

    {updated_player, updated_enemy, text} =
      case attacker do
        :player ->
          updated_enemy = %{enemy | health: enemy.health - damage}
          text = format_text(roll, updated_enemy.name, damage)
          {player, updated_enemy, text}

        :enemy ->
          updated_player = %{player | health: player.health - damage}
          text = format_text(roll, updated_player.name, damage)
          {updated_player, enemy, text}
      end

    {updated_player, updated_enemy, text}
  end

  defp format_text(roll, name, damage) do
    if roll < 5 do
      "#{roll}: Svagt slag – #{name} tog #{damage} skada."
    else
      "#{roll}: KRAFTTRÄFF! #{name} tog #{damage} skada."
    end
  end
end
