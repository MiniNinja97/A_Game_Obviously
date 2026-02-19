defmodule MyApp.GameLive do
  use MyAppWeb, :live_view

  alias MyApp.Game.GameServer
  @impl true
  def mount(_params, _session, socket) do
    user = socket.asssigns.current_user

    {:ok, _} = GameServer.start_link(user.id)

    Phoenix.PubSub.subscribe(
      MyApp.PubSub,
      "game:#{user.name}"
    )

    state = GameServer.get_state(user.id)

    {:ok, assign(socket, state: state, input: "")}
  end
  @impl true
  def handle_event("send_command", %{"command" => cmd}, socket) do
    GameServer.command(socket.assigns.current_user.id, cmd)
    {:noreply, assign(socket, input: "")}
  end
  @impl true
  def handle_info({:state_updated, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

   @impl true
  def render(assigns) do
    ~H"""
    <div class="terminal">
      <%= for line <- Enum.reverse(@state.log) do %>
        <div>{line}</div>
      <% end %>
    </div>

    <form phx-submit="send_command">
      <input
        name="command"
        value={@input}
        autocomplete="off"
        placeholder="Skriv command..."
      />
    </form>
    """
  end
end
