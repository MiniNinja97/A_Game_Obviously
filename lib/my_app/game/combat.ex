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

        # ---- PLAYER TURN ----
        roll = Dice.roll(6)
        damage = trunc(state.player.attack * (roll / 10))

        new_enemy = %{enemy | health: enemy.health - damage}

        player_log =
          "#{roll}: You attack the #{enemy.name} for #{damage} damage!"

        # Uppdatera state efter player attack
        state_after_player =
          state
          |> put_in([:room, :enemy], new_enemy)

        # Kolla om enemy dog
        if new_enemy.health <= 0 do
          final_state =
            state_after_player
            |> Map.put(:phase, :road)
            |> put_in([:room, :enemy], nil)

          {
            final_state,
            [
              %{type: :log, text: player_log},
              %{type: :log, text: "🏆 You defeated the #{enemy.name}!"}
            ]
          }
        else
          # ---- ENEMY TURN ----
          enemy_roll = Dice.roll(6)
          enemy_damage = trunc(enemy.attack * (enemy_roll / 10))

          new_player =
            %{state.player | health: state.player.health - enemy_damage}

          enemy_log =
            "#{enemy_roll}: The #{enemy.name} attacks you back for #{enemy_damage} damage!"

          updated_state =
            state_after_player
            |> Map.put(:player, new_player)

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
          {
            state
            |> Map.put(:phase, :road)
            |> Map.put(:room, nil),
            [%{type: :log, text: "You successfully ran away!"}]
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
        {state,
         [%{type: :log, text: "Uhm whut? Try 'attack' or 'run'."}]}
    end
  end

  # ---- DEATH CHECK ----

  defp check_player_death(state) do
    if state.player.health <= 0 do
      new_state = %{state | phase: :game_over}

      {
        new_state,
        [%{type: :log, text: "💀 You were slain in battle!"}]
      }
    else
      {state, []}
    end
  end
end
