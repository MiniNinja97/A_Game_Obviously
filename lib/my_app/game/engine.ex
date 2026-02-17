defmodule FiskWebWeb.Game.Fisk do
  alias Dice

  # ======================
  # Public API
  # ======================

  def new_game do
    player = make_living("Hero", 100, 30)

    room = %{
      name: "Random Room",
      enemy: random_enemy(),
      items: []
    }

    %{
      player: player,
      room: room,
      log: ""
    }
  end

  def handle_command(state, :attack) do
    bf = make_battle_field(state.player, state.room.enemy)

    {bf_after, events} = battle_round(bf, :player)

    new_game = %{
      state
      | player: bf_after.player,
        room: %{state.room | enemy: bf_after.enemy}
    }

    {new_game, events}
  end

  def handle_command(state, :run) do
    {state, [%{type: :log, text: "Du flyr från striden"}]}
  end

  # ======================
  # Battle logic
  # ======================

  def battle_round(bf, attacker) do
    p = bf.player
    e = bf.enemy

    roll = Dice.roll(6)

    base_attack =
      case attacker do
        :player -> p.attack
        :enemy -> e.attack
      end

    damage = trunc(base_attack * (roll / 10))

    {defender_key, defender} =
      case attacker do
        :player ->
          {:enemy, %{e | health: e.health - damage}}

        :enemy ->
          {:player, %{p | health: p.health - damage}}
      end

    text =
      if roll < 5 do
        "#{roll}: Svagt slag – #{defender.name} tog #{damage} skada."
      else
        "#{roll}: KRAFTTRÄFF! #{defender.name} tog #{damage} skada."
      end

    bf
    |> Map.put(defender_key, defender)
    |> log(text)
  end

  # ======================
  # Helpers
  # ======================

  def log(bf, text) do
    {
      bf,
      [%{type: :log, text: text}]
    }
  end

  def make_living(name, health, attack) do
    %{name: name, health: health, attack: attack, inventory: []}
  end

  defp make_battle_field(player, enemy) do
    %{player: player, enemy: enemy}
  end

  def random_enemy do
    [
      make_living("Goblin", 50, 10),
      make_living("Orc", 80, 15),
      make_living("Troll", 120, 20)
    ]
    |> Enum.random()
  end
end
