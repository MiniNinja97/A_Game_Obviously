defmodule MyAppWeb.GameMenuLive do
  use MyAppWeb, :live_view




  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    {:ok,
     assign(socket,
       user: user,
       has_active_game: false,
       score: 0
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-menu">
      <h1>Välkommen <%= @user.email %></h1>

      <div class="menu-section">
        <h2>Score</h2>
        <p><%= @score %> poäng</p>
      </div>

      <div class="menu-section">
        <button phx-click="new_game">Starta nytt spel</button>
      </div>

      <div :if={@has_active_game} class="menu-section">
        <button phx-click="continue_game">Fortsätt spel</button>
      </div>

      <div class="menu-section">
        <.link href={~p"/users/log-out"} method="delete" class="btn-logout">
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
