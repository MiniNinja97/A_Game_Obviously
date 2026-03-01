defmodule MyApp.Game.Combat do
  alias MyApp.Game.{State, Dice}

  @doc """
  Handles combat commands like "attack" and "run".
  """

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :combat} = state, command) do
    case command do
      "attack" ->
        enemy = state.room.enemy

        # Player attack roll (med crit/miss)
        roll = Dice.roll(12)

        {damage, player_log} =
          cond do
            roll >= 11 ->
              dmg = trunc(state.player.attack * (roll / 3))
              log = "#{roll}: CRITICAL HIT! You smash the #{enemy.name} for #{dmg} damage!"
              {dmg, log}

            roll <= 2 ->
              dmg = trunc(state.player.attack * (roll / 12))

              log =
                "#{roll}: OOPS! You trip and barely hit the #{enemy.name} for #{dmg} damage!"

              {dmg, log}

            true ->
              dmg = trunc(state.player.attack * (roll / 6))
              log = "#{roll}: You attack the #{enemy.name} for #{dmg} damage."
              {dmg, log}
          end

        new_enemy = %{enemy | health: enemy.health - damage}
        new_room = %{state.room | enemy: new_enemy}
        state_after_player = %{state | room: new_room}

        if new_enemy.health <= 0 do
          # Combat vunnen → belöning
          new_player =
            state_after_player.player
            |> Map.update!(:health, &(&1 + 10))
            |> Map.update!(:attack, &(&1 + 10))
            # +1 XP, lägg till om du har xp
            |> Map.update(:xp, 0, &(&1 + 1))

          final_state = %{
            state_after_player
            | phase: :road,
              room: %{state_after_player.room | enemy: nil},
              player: new_player
          }

          {
            final_state,
            [
              %{type: :log, text: player_log},
              %{
                type: :log,
                text: "You defeated the #{enemy.name}! You gain +10 Health and +10 Attack!"
              }
            ]
          }
        else
          # Enemy turn
          enemy_roll = Dice.roll(12)
          enemy_damage = trunc(enemy.attack * (enemy_roll / 6))

          new_player = %{
            state_after_player.player
            | health: state_after_player.player.health - enemy_damage
          }

          enemy_log =
            "#{enemy_roll}: The #{enemy.name} attacks you back for #{enemy_damage} damage!"

          updated_state = %{state_after_player | player: new_player}
          {final_state, death_logs} = check_player_death(updated_state)

          {
            final_state,
            [
              %{type: :log, text: player_log},
              %{type: :log, text: enemy_log}
            ] ++ death_logs
          }
        end

      "run" ->
        roll = Dice.roll(6)

        if roll >= 4 do
          # Lyckad run → belöning intellect
          new_player = Map.update(state.player, :intellect, 0, &(&1 + 10))

          {
            %{
              state
              | phase: :road,
                room: nil,
                player: new_player
            },
            [
              %{
                type: :log,
                text: "You successfully ran away! +10 Intellect for quick thinking!"
              }
            ]
          }
        else
          {
            state,
            [
              %{
                type: :log,
                text:
                  "Well that was an embarrassing attempt to run away! You failed! Now you must fight."
              }
            ]
          }
        end

      _ ->
        {state, [%{type: :log, text: "Uhm whut? Try 'attack' or 'run'."}]}
    end
  end

  # ---- DEATH CHECK ----

  defp check_player_death(state) do
    if state.player.health <= 0 do
      new_state = %{state | phase: :game_over}

      MyApp.Game.maybe_game_over(
        new_state,
        "You were slain in battle!"
      )
    else
      {state, []}
    end
  end
end
