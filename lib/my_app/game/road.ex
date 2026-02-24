defmodule MyApp.Game.Road do
  alias MyApp.Game.{State, Room}

  @road_texts [
    "Du känner vinden mot ansiktet.",
    "En korp kraxar i fjärran.",
    "Du trampar på en lös sten.",
    "Du hör något skramla bland buskarna."
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
              %{type: :log, text: "En ny plats dyker upp: #{room.name}"},
              %{type: :log, text: room.description},
              %{
                type: :log,
                text:
                  "Du kan nu: 'go straight forward', 'go left', 'go right', 'search', eller 'inventory'."
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
