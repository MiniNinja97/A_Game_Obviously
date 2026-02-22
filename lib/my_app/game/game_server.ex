defmodule MyApp.Game.GameServer do
  use GenServer

  alias MyApp.Game.Engine

  # ==========
  # PUBLIC API
  # ==========

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via(user_id))
  end

  def command(user_id, text) do
    GenServer.cast(via(user_id), {:command, text})
  end

  def set_state(user_id, new_state) do
    GenServer.cast(via(user_id), {:set_state, new_state})
  end

  def get_state(user_id) do
    GenServer.call(via(user_id), :get_state)
  end

  defp via(user_id) do
    {:via, Registry, {MyApp.GameRegistry, user_id}}
  end

  # ==========
  # CALLBACKS
  # ==========

  @impl true
  def init(user_id) do
    game_state = Engine.new_game()

    # Skicka initial log direkt till LiveView
    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{user_id}",
      {:game_events, game_state.log}
    )

    {:ok, %{game: game_state, user_id: user_id}}
  end

  @impl true
  def handle_call(:get_state, _from, %{game: game} = state) do
    {:reply, game, state}
  end

  @impl true
  def handle_cast({:command, text}, %{game: game, user_id: user_id} = state) do
    # Engine.handle_input returnerar nu {new_state, events}
    {new_game, events} = Engine.handle_input(game, text)

    # Skicka bara de nya log-events till LiveView
    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{user_id}",
      {:game_events, events}
    )

    {:noreply, %{state | game: new_game}}
  end

  @impl true
  def handle_cast({:set_state, new_state}, state) do
    {:noreply, %{state | game: new_state}}
  end
end
