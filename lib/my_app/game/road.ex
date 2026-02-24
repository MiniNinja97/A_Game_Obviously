defmodule MyApp.Game.Road do
  alias MyApp.Game.{State, Room}

  @road_texts [
  "You feel the wind on your face.",
  "A raven caws in the distance.",
  "You step on a loose stone.",
  "You hear something rattling in the bushes."
]

  @spec handle(State.t(), String.t()) :: {State.t(), list(map())}
  def handle(%State{phase: :road} = state, command) do
    cmd = String.trim(command) |> String.downcase()

    if cmd == "move" do
      case state.road_visits do
        # =====================
        # Första move → visa slumpad road-text
        # =====================
        0 ->
          text = Enum.random(@road_texts)

          new_state = %State{
            state
            | road_visits: 1
          }

          {new_state, [%{type: :log, text: text}]}

        # =====================
        # Andra move → gå till room
        # =====================
        1 ->
          room = Room.random_room()

          new_state = %State{
            state
            | phase: :room,
              location: :room,
              room: room,
              road_visits: 0
          }

          {
            new_state,
            [
              %{type: :log, text: "A new place emerges frow afar: #{room.name}"},
              %{type: :log, text: room.description},
              %{
                type: :log,
                text:
                  "You can: 'go straight forward', 'go left', 'go right', 'search', eller 'inventory'."
              }
            ]
          }
      end
    else
      {state,
       [%{type: :log, text: "Huh whut? If you wanna move forward you have to write 'move'"}]}
    end
  end
end
