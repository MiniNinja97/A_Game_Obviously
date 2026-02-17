defmodule MyApp.Game.State do
  defstruct [
    :player,
    :rooms,
    :current_room,
    log: [],
    status: :playing
  ]
end
