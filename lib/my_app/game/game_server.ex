defmodule MyApp.Game.GameServer do
  use GenServer

  alias MyApp.Game.Engine
  alias MyApp.Game.State

  def start_link(user_id) do
    GenServer.start_link(_MODULE_, user_id, name: via(user_id))
  end

  def command(user_id, text) do
    GenServer.cast(via(user_id), {:command, text})
  end

  def get_state(user_id) do
    GenServer.call(via(user_id), :get_state)
  end

  defp via(user_id) do
    {:via, Registry, {MyApp.GameRegistry, user_id}}
  end

  @impl true
  def init(user_id) do
    state = Engine.new_game(user_id)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:command, text}, state) do
    new_state = Engine.handle_input(state, text)

    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{state.player.name}",
      {:state_updated, new_state}
    )

    {:noreply, new_state}
  end
end
