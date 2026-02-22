defmodule MyApp.Game.GameServer do
  use GenServer

  alias MyApp.Game.Engine

  @doc """
  GenServer that manages one game session per user.
  """

  # ==========
  # PUBLIC API
  # ==========

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via(user_id))
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

  # ==========
  # CALLBACKS
  # ==========

  @impl true
  def init(user_id) do
    game = Engine.new_game()

    {:ok, %{game: game, user_id: user_id}}
  end

  @impl true
  def handle_call(:get_state, _from, %{game: game} = state) do
    {:reply, game, state}
  end

  @impl true
  def handle_cast({:command, text}, %{game: game, user_id: user_id} = state) do
    {new_game, events} = Engine.handle_input(game, text)

    # Lägg till events i loggen här (centraliserat)
    updated_game = %{
      new_game
      | log: new_game.log ++ events
    }

    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "game:#{user_id}",
      {:state_updated, updated_game}
    )

    {:noreply, %{state | game: updated_game}}
  end
end
