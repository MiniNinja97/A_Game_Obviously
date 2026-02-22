defmodule MyAppWeb.GameLive do
  use MyAppWeb, :live_view

  alias MyApp.Game.GameServer

  @log_delay 5_000

  @doc """
  Mounts the LiveView, starts the GameServer if needed,
  subscribes to PubSub, initializes timer and staged log display.
  """
  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Start GameServer if not already started
    case GameServer.start_link(user.id) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    # Subscribe to PubSub
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "game:#{user.id}")
      :timer.send_interval(1000, self(), :tick)
    end

    state = GameServer.get_state(user.id)

    socket =
      socket
      |> assign(:state, state)
      |> assign(:input, "")
      |> assign(:seconds_played, 0)
      |> assign(:started_at, DateTime.utc_now())
      |> assign(:displayed_log, [])
      |> assign(:pending_log, Map.get(state, :log, []))

    # Start delayed log output if connected
    if connected?(socket) do
      Process.send_after(self(), :log_tick, @log_delay)
    end

    {:ok, socket}
  end

  @doc """
  Handles the 1-second game timer.
  """
  @impl true
  def handle_info(:tick, socket) do
    {:noreply, update(socket, :seconds_played, &(&1 + 1))}
  end


  @impl true
  def handle_info(:log_tick, socket) do
    case socket.assigns.pending_log do
      [next | rest] ->
        Process.send_after(self(), :log_tick, @log_delay)

        {:noreply,
         socket
         |> update(:displayed_log, &(&1 ++ [next]))
         |> assign(:pending_log, rest)}

      [] ->
        {:noreply, socket}
    end
  end


  @impl true
  def handle_info({:state_updated, new_state}, socket) do
    {:noreply,
     socket
     |> assign(:state, new_state)
     |> assign(:pending_log, Map.get(new_state, :log, []))
     |> assign(:displayed_log, [])}
  end

  @doc """
  Handles user input from the Send button.
  In :intro phase it acts as Continue.
  Otherwise it sends command to GameServer.
  """
 @impl true
def handle_event("send_command", %{"command" => command}, socket) do
  user_id = socket.assigns.current_scope.user.id

  socket =
    case socket.assigns.state.phase do
      :intro ->
        continue_log(socket)

      _ ->
        GameServer.command(user_id, command)
        socket
    end

  {:noreply, assign(socket, :input, "")}
end


  defp continue_log(socket) do
    case socket.assigns.pending_log do
      [next | rest] ->
        socket
        |> update(:displayed_log, &(&1 ++ [next]))
        |> assign(:pending_log, rest)

      [] ->
        socket
    end
  end

  @doc """
  Renders the game interface including status panel,
  staged terminal log and input form.
  """
  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-wrapper">
      <div class="game-card">
        <div class="status-panel">
          <%= if @state.player do %>
            <div class="status-item">
              <span>Player</span>
              <strong><%= @state.player.name %></strong>
            </div>

            <div class="status-item">
              <span>Attack</span>
              <strong><%= @state.player.attack %></strong>
            </div>

            <div class="status-item">
              <span>Health</span>
              <strong><%= @state.player.health %></strong>
            </div>

            <div class="status-item">
              <span>Intellect</span>
              <strong><%= @state.player.intellect %></strong>
            </div>

            <div class="status-item">
              <span>Gold</span>
              <strong><%= @state.player.gold %></strong>
            </div>
          <% end %>

          <div class="status-item">
            <span>Phase</span>
            <strong><%= @state.phase %></strong>
          </div>

          <div class="status-item">
            <span>Time</span>
            <strong><%= @seconds_played %>s</strong>
          </div>
        </div>

        <div class="terminal">
          <%= for event <- @displayed_log do %>
            <div class="log-line">
              <%= event.text %>
            </div>
          <% end %>
        </div>

        <form phx-submit="send_command" class="command-form">
          <input
            type="text"
            name="command"
            value={@input}
            placeholder="Type command..."
            autocomplete="off"
          />
          <button type="submit">
            <%= if @state.phase == :intro, do: "Continue", else: "Send" %>
          </button>
        </form>
      </div>
    </div>
    """
  end
end
