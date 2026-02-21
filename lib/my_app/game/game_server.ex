defmodule MyApp.Game.GameServer do
  use GenServer

  alias MyApp.Game.Engine

@doc """
  GenServer som hanterar varje spelares individuella spelomgång.
  Tar emot kommandon, uppdaterar spelstatus och skickar uppdateringar via PubSub.
"""
  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via(user_id))
  end

  @doc """
  Extern API för att skicka kommandon till spelomgången och hämta aktuell status.
  """
  def command(user_id, text) do
    GenServer.cast(via(user_id), {:command, text})
  end

  @doc """
  Hämtar aktuell spelstatus för en användare.
   Används av LiveView för att rendera gränssnittet.
   Returnerar hela spelstatusen som en map.
   Exempel: %{player: %{name: "Hero", health: 100}, phase: :road, log: [...]}
   Kan utökas med specifika getters för enklare åtkomst till delar av statusen.
   Exempel: get_player(user_id) som returnerar player-delen av statusen.
   Eller get_phase(user_id) som returnerar nuvarande fas i spelet.
  """
  def get_state(user_id) do
    GenServer.call(via(user_id), :get_state)
  end


  defp via(user_id) do
    {:via, Registry, {MyApp.GameRegistry, user_id}}
  end


  @doc """
  GenServer callbacks för att hantera initiering, inkommande kommandon och statusförfrågningar.
   init/1 skapar en ny spelomgång med Engine.new_game och returnerar initial status.
   handle_call/3 hanterar synkrona anrop som get_state och returnerar aktuell status.
   handle_cast/2 hanterar asynkrona kommandon, uppdaterar spelstatus med Engine.handle_input och skickar uppdateringar via PubSub.
  """
  @impl true
def init(user_id) do
  state = Engine.new_game(user_id)

  {:ok, %{game: state, user_id: user_id}}
end


@doc """
  GenServer callback för att hantera synkrona anrop som get_state.
   Returnerar aktuell spelstatus.
  """

 @impl true
def handle_call(:get_state, _from, %{game: game} = state) do
  {:reply, game, state}
end


  @doc """
  GenServer callback för att hantera asynkrona kommandon.
   Tar emot kommandon som "move", "attack", etc., uppdaterar spelstatus med Engine.handle_input och skickar uppdateringar via PubSub.
  """
 @impl true
def handle_cast({:command, text}, %{game: game, user_id: user_id} = state) do
  new_game = Engine.handle_input(game, text)

  Phoenix.PubSub.broadcast(
    MyApp.PubSub,
    "game:#{user_id}",
    {:state_updated, new_game}
  )

  {:noreply, %{state | game: new_game}}
end
end
