defmodule MyAppWeb.GameLive do
  use MyAppWeb, :live_view

  alias MyApp.Game.GameServer
  alias MyApp.Game.State


  @log_delay 1200

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Starta GameServer om den inte redan finns
    case GameServer.start_link(user.id) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "game:#{user.id}")

      state = GameServer.get_state(user.id)

      socket =
        socket
        |> assign(:state, state)
        |> assign(:input, "")
        |> assign(:seconds_played, 0)
        |> assign(:displayed_log, [])
        |> assign(:pending_log, Map.get(state, :log, []))

      if length(socket.assigns.pending_log) > 0 do
        Process.send_after(self(), :log_tick, @log_delay)
      end

      :timer.send_interval(1000, self(), :tick)
      {:ok, socket}
    else
      # CHANGE: Använd State.new() för pre-intro när LiveView inte är ansluten
      initial_state = State.new()

      socket =
        socket
        |> assign(:state, initial_state)
        |> assign(:input, "")
        |> assign(:seconds_played, 0)
        |> assign(:displayed_log, [])
        |> assign(:pending_log, initial_state.log)

      Process.send_after(self(), :log_tick, @log_delay)

      {:ok, socket}
    end
  end

  # =====================
  # HANDLE GAME EVENTS
  # =====================

  @impl true
  def handle_info({:game_events, events}, socket) do
    socket =
      socket
      |> update(:pending_log, &(&1 ++ events))
      |> maybe_start_log_tick()

    {:noreply, socket}
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
  def handle_info(:tick, socket) do
    {:noreply, update(socket, :seconds_played, &(&1 + 1))}
  end

  # =====================
  # USER INPUT
  # =====================

  # OLD HANDLE_EVENT preserved:
  # @impl true
  # def handle_event("send_command", %{"command" => command}, socket) do
  #   state = socket.assigns.state
  #
  #   if state.phase == :character_creation and is_nil(state.player) do
  #     {new_state, events} = Intro.handle(state, command)
  #
  #     socket =
  #       socket
  #       |> assign(:state, new_state)
  #       |> update(:displayed_log, &(&1 ++ events)) # direkt i displayed_log så det syns
  #       |> assign(:input, "")
  #
  #     {:noreply, socket}
  #   else
  #     # När player finns, skicka input till GameServer
  #     user_id = socket.assigns.current_scope.user.id
  #     GameServer.command(user_id, command)
  #     {:noreply, assign(socket, :input, "")}
  #   end
  # end

@impl true
def handle_event("send_command", %{"command" => command}, socket) do
  state = socket.assigns.state
  command = String.trim(command) |> String.replace(~r/^"|"$/, "")

  cond do
    # =====================
    # CHARACTER CREATION
    # =====================
    state.phase == :character_creation and is_nil(state.player) ->
      {new_state, events} = MyApp.Game.Intro.handle(state, command)

      # Uppdatera LiveView (GameServer kan ignoreras här)
      socket =
        socket
        |> assign(:state, new_state)
        |> update(:displayed_log, &(&1 ++ events))
        |> assign(:input, "")

      {:noreply, socket}

    # =====================
    # ALL OTHER PHASES → Engine direkt
    # =====================
    true ->
      {new_state, events} = MyApp.Game.Engine.handle_input(state, command)

      socket =
        socket
        |> assign(:state, new_state)
        |> update(:displayed_log, &(&1 ++ events))
        |> assign(:input, "")

      {:noreply, socket}
  end
end

  # =====================
  # INTERNAL HELPERS
  # =====================

  defp maybe_start_log_tick(socket) do
    if length(socket.assigns.pending_log) == 1 do
      Process.send_after(self(), :log_tick, @log_delay)
    end

    socket
  end

  # =====================
  # RENDER
  # =====================

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
            Continue
          </button>
        </form>

      </div>
    </div>
    """
  end
end
