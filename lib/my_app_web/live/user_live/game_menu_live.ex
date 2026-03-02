defmodule MyAppWeb.GameMenuLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    games = MyApp.Game.list_finished_games(user.id)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:games, games)
     |> assign(:has_active_game, false)
     |> assign(:score, 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-menu">
      <h1>Välkommen {@user.email}</h1>

      <div class="menu-section">
        <h2>Tidigare spel</h2>

        <%= if @games == [] do %>
          <p>Inga tidigare spel ännu.</p>
        <% else %>
          <%= for game <- @games do %>
            <div class="score-card">
              <div class="status-item">
                <span>Namn</span>
                <strong>{game.character_name}</strong>
              </div>

              <div class="status-item">
                <span>Start</span>
                <strong>{game.started_at}</strong>
              </div>

              <div class="status-item">
                <span>Slut</span>
                <strong>{game.finished_at || game.ended_at}</strong>
              </div>

              <%= if game.state do %>
                <div class="status-item">
                  <span>Health</span>
                  <strong>{game.state["health"]}</strong>
                </div>

                <div class="status-item">
                  <span>Gold</span>
                  <strong>{game.state["gold"]}</strong>
                </div>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>

      <div class="menu-section">
        <button phx-click="new_game">
          Starta nytt spel
        </button>
      </div>

      <div :if={@has_active_game} class="menu-section">
        <button phx-click="continue_game">
          Fortsätt spel
        </button>
      </div>

      <div class="menu-section">
        <.link
          href={~p"/users/log-out"}
          method="delete"
          class="btn-logout"
        >
          Logga ut
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("new_game", _, socket) do
    {:noreply, push_navigate(socket, to: "/game")}
  end

  @impl true
  def handle_event("continue_game", _, socket) do
    {:noreply, push_navigate(socket, to: "/game")}
  end
end
