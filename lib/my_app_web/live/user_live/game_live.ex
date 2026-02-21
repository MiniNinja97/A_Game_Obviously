defmodule MyAppWeb.GameLive do
  use MyAppWeb, :live_view

  alias MyApp.Game.GameServer

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Starta GameServer om den inte redan kör
    case GameServer.start_link(user.id) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    # Prenumerera på PubSub
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "game:#{user.id}")
    end

    # Hämta initial state
    state = GameServer.get_state(user.id)

    {:ok,
     socket
     |> assign(:state, state)
     |> assign(:input, "")}
  end

  # När GameServer broadcastar uppdatering
  @impl true
  def handle_info({:state_updated, new_state}, socket) do
    {:noreply, assign(socket, :state, new_state)}
  end

  # När spelaren skickar input
  @impl true
  def handle_event("send_command", %{"command" => command}, socket) do
    user = socket.assigns.current_scope.user

    GameServer.command(user.id, command)

    {:noreply, assign(socket, :input, "")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-container">

      <div class="status">
        <p><strong>Player:</strong> <%= @state.player.name %></p>
        <p><strong>Health:</strong> <%= @state.player.health %></p>
        <p><strong>Gold:</strong> <%= @state.player.gold %></p>
        <p><strong>Phase:</strong> <%= @state.phase %></p>
      </div>

      <div class="terminal">
        <%= for event <- Enum.reverse(Map.get(@state, :log, [])) do %>
          <div class="log-line">
            <%= event.text %>
          </div>
        <% end %>
      </div>

      <form phx-submit="send_command">
        <input
          type="text"
          name="command"
          value={@input}
          placeholder="Type command..."
          autocomplete="off"
        />
        <button type="submit">Send</button>
      </form>

    </div>
    """
  end
end
