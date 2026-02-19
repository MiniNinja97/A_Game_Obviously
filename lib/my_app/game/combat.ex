defmodule MyApp.Game.Combat do
  alias MyApp.Game.{State, Dice}

  @doc """
  Handles combat commands like "attack" and "run".
  """

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :combat} = state, command) do
    case command do
      "attack" ->
        roll = Dice.roll(6)
        damage = trunc(state.player.attack * (roll / 10))
        enemy = state.room.enemy
        new_enemy = %{enemy | health: enemy.health - damage}

        log_text =
          "#{roll}: You attack the #{enemy.name} for #{damage} damage!"

        enemy_roll = Dice.roll(6)
        enemy_damage = trunc(enemy.attack * (enemy_roll / 10))
        new_player = %{state.player | health: state.player.health - enemy_damage}

        log_text2 =
          "#{enemy_roll}: The #{enemy.name} attacks you back for #{enemy_damage} damage!"

        {new_phase, log_text3} =
          cond do
            new_player.health <= 0 ->
              {:game_over, "You died! Game Over."}

            new_enemy.health <= 0 ->
              {:road,
               "You defeated the #{enemy.name}! You can now go back to the road."}

            true ->
              {:combat, nil}
          end

        new_state = %State{
          state
          | phase: new_phase,
            player: new_player,
            room: %{state.room | enemy: new_enemy}
        }

        logs = [
          %{type: :log, text: log_text},
          %{type: :log, text: log_text2}
        ]

        logs =
          if log_text3,
            do: logs ++ [%{type: :log, text: log_text3}],
            else: logs

        {new_state, logs}

      "run" ->
        roll = Dice.roll(6)

        if roll >= 4 do
          {
            state |> Map.put(:phase, :road) |> Map.put(:room, nil),
            [%{type: :log, text: "You successfully ran away!"}]
          }
        else
          {
            state,
            [
              %{
                type: :log,
                text:
                  "Well that was an embarrasing attempt to run away! You failed! Now you must fight."
              }
            ]
          }
        end

      _ ->
        {state,
         [%{type: :log, text: "Uhm whut? Try 'attack' or 'run'."}]}
    end
  end
end
