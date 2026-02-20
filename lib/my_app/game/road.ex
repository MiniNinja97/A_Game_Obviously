defmodule MyApp.Game.Road do
  alias MyApp.Game.{State, Room}

  @road_texts [
    "Du känner vinden mot ansiktet.",
    "En korp kraxar i fjärran.",
    "Du trampar på en lös sten.",
    "Du hör något skramla bland buskarna."
  ]

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :road} = state, "Move") do

    texts = Enum.take_random(@road_texts, Enum.random(2..4))
    new_log = state.log ++ texts

    if state.road_visits < 3 do

      room = Room.random_room()
      new_state = %State{
        state |
        phase: :room,
        location: :room,
        room: room,
        road_visits: state.road_visits + 1,
        log: new_log
      }

      {new_state, [%{type: :log, text: "En ny plats dyker upp #{room.name}"}]}

    else
      new_state = %State{state | log: new_log}
      {new_state, [%{type: :log, text: "Du ser något långt där borta"}]}
    end
  end

  def handle(%State{} = state, _command) do
    {state, [%{type: :log, text: "Huh whut? I u wanna move forward you have to write 'move'"}]}

  end



end
