defmodule MyApp.Game.Tavern do
  alias MyApp.Game.State

  @riddle_answer "a map"

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: phase} = state, command) when phase in [:tavern, :tavern_bar] do
    cmd = String.trim(command) |> String.downcase()

    cond do
      Map.get(state.room || %{}, :riddle_active) ->
        handle_riddle_answer(state, cmd)

      true ->
        case cmd do
          "sleep" -> handle_sleep(state)
          "eat" -> handle_eat(state)
          "to the bar" -> handle_bar(state)
          "challenge" -> handle_challenge(state)
          "rob" -> handle_rob(state)
          _ ->
            hint =
              if state.phase == :tavern_bar do
                "Try 'challenge' or 'rob'."
              else
                "Try 'sleep', 'eat', or 'to the bar'."
              end
            {state, [%{type: :log, text: "Hm? #{hint}"}]}
        end
    end
  end

  # =====================
  # ENTER TAVERN
  # =====================
  def enter(state) do
    new_state = %State{state | phase: :tavern}

    {new_state, [
      %{type: :log, text: "Through the fog you see a dim light ahead."},
      %{type: :log, text: "As you get closer you realize it's a tavern. ->"},
      %{type: :log, text: "You push open the creaky door and step inside."},
      %{type: :log, text: "The warmth hits you immediately. A fire crackles in the corner. ->"},
      %{type: :log, text: "Somewhere in the back a fiddle is playing, low and easy."},
      %{type: :log, text: "People sit at tables, eating, talking quietly. Nobody pays you much attention. ->"},
      %{type: :log, text: "It feels safe here. Almost too safe."},
      %{type: :log, text: "Your eyes wander to the bar. An old man sits alone at the far end. ->"},
      %{type: :log, text: "You don't know why, but something about him feels familiar. ->"},
      %{type: :log, text: "You could use some rest though. Or maybe some food."},
      %{type: :log, text: "Type 'sleep' to rest, 'eat' to grab a bite, or 'to the bar' to approach the old man."}
    ]}
  end

  # =====================
  # SLEEP
  # =====================
  defp handle_sleep(state) do
    new_player = %{state.player | health: 100}
    new_state = %State{state | player: new_player, phase: :tavern_bar}

    {new_state, [
      %{type: :log, text: "You find a dusty cot in the corner and collapse into it. ->"},
      %{type: :log, text: "You sleep like the dead. Health restored to 100. ->"},
      %{type: :log, text: "When you wake up the tavern is quieter. ->"},
      %{type: :log, text: "The fiddle has stopped. Most people have gone. ->"},
      %{type: :log, text: "But the old man at the bar hasn't moved. ->"},
      %{type: :log, text: "You don't even decide to walk over. Your feet just take you there."},
      %{type: :log, text: "Type 'to the bar' to approach him."}
    ]}
  end

  # =====================
  # EAT
  # =====================
  defp handle_eat(state) do
    new_player = %{state.player |
      health: state.player.health + 50,
      attack: state.player.attack + 50
    }
    new_state = %State{state | player: new_player, phase: :tavern_bar}

    {new_state, [
      %{type: :log, text: "You grab a seat and order whatever they're serving. ->"},
      %{type: :log, text: "It tastes terrible. You eat every last bite. +50 Health, +50 Attack. ->"},
      %{type: :log, text: "You lean back and watch the room for a while."},
      %{type: :log, text: "But your eyes keep drifting back to the old man at the bar. ->"},
      %{type: :log, text: "You're not sure why. You just know you have to go over there."},
      %{type: :log, text: "Type 'to the bar' to approach him."}
    ]}
  end

  # =====================
  # TO THE BAR
  # =====================
  defp handle_bar(state) do
    new_state = %State{state | phase: :tavern_bar}

    {new_state, [
      %{type: :log, text: "You walk up to the bar and take a seat beside the old man. ->"},
      %{type: :log, text: "He slowly turns to look at you. His eyes are sharp. Too sharp for someone his age. ->"},
      %{type: :log, text: "\"Ah. You made it,\" he says, as if he already knew you would. ->"},
      %{type: :log, text: "\"I've been watching your little journey. Not bad. Not great. But not bad.\" ->"},
      %{type: :log, text: "He takes a slow sip of his drink."},
      %{type: :log, text: "\"I have a challenge for you. Answer my riddle and I'll give you something useful.\" ->"},
      %{type: :log, text: "\"Don't feel like playing along? You're welcome to try your luck on the way out.\""},
      %{type: :log, text: "Type 'challenge' to accept the riddle, or 'rob' to try your luck."}
    ]}
  end

  # =====================
  # CHALLENGE / RIDDLE
  # =====================
  defp handle_challenge(state) do
    new_room = Map.put(state.room || %{}, :riddle_active, true)
    new_state = %State{state | room: new_room}

    {new_state, [
      %{type: :log, text: "The old man sets down his drink and turns to face you fully. ->"},
      %{type: :log, text: "\"Good. I like someone who isn't afraid.\""},
      %{type: :log, text: "He leans in close. ->"},
      %{type: :log, text: "\"I have cities, but no houses live there."},
      %{type: :log, text: "I have mountains, but no trees grow there."},
      %{type: :log, text: "I have water, but no fish swim there."},
      %{type: :log, text: "I have roads, but no one walks there."},
      %{type: :log, text: "What am I?\""},
      %{type: :log, text: "Type your answer and press continue."}
    ]}
  end

  defp handle_riddle_answer(state, answer) do
    if String.downcase(String.trim(answer)) == @riddle_answer do
      handle_riddle_correct(state)
    else
      handle_riddle_wrong(state)
    end
  end

  defp handle_riddle_correct(state) do
    new_room = Map.put(state.room, :riddle_active, false)
    new_state = %State{state | phase: :victory, room: new_room}

    {new_state, [
      %{type: :log, text: "The old man stares at you for a long moment. ->"},
      %{type: :log, text: "Then, slowly, he smiles."},
      %{type: :log, text: "\"A map,\" he says quietly. \"You said a map. Well done.\" ->"},
      %{type: :log, text: "He reaches into his coat and slides a folded piece of parchment across the bar."},
      %{type: :log, text: "\"There are more roads out there. More rooms. More things that will try to kill you.\" ->"},
      %{type: :log, text: "\"Good luck with the quests to come, traveller.\""},
      %{type: :log, text: "He turns back to his drink. The conversation is over."},
      %{type: :log, text: "You pocket the map and head for the door, feeling like something has just begun. ->"}
    ]}
  end

  defp handle_riddle_wrong(state) do
    new_state = %State{state | phase: :game_over}

    {new_state, [
      %{type: :log, text: "The old man sighs deeply."},
      %{type: :log, text: "\"I thought you'd learned enough by now.\""},
      %{type: :log, text: "He snaps his fingers. ->"},
      %{type: :log, text: "The world goes dark."}
    ]}
  end

  # =====================
  # ROB
  # =====================
  defp handle_rob(state) do
    intellect = state.player.intellect || 0

    if intellect > 30 do
      new_state = %State{state | phase: :victory}

      {new_state, [
        %{type: :log, text: "You stand up casually and start heading for the door."},
        %{type: :log, text: "As you pass behind the old man you move quick and quiet."},
        %{type: :log, text: "Your hand finds something in his coat pocket — a folded piece of parchment."},
        %{type: :log, text: "A map."},
        %{type: :log, text: "You slip out the door before he notices. Or maybe he did notice."},
        %{type: :log, text: "Maybe he let you."},
        %{type: :log, text: "Either way, you have the map. And the road ahead is yours. ->"}
      ]}
    else
      new_state = %State{state | phase: :game_over}

      {new_state, [
        %{type: :log, text: "The old man sighs deeply."},
        %{type: :log, text: "\"I thought you'd learned enough by now.\""},
        %{type: :log, text: "He snaps his fingers. ->"},
        %{type: :log, text: "The world goes dark."}
      ]}
    end
  end
end
