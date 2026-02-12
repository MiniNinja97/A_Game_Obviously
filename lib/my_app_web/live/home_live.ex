defmodule MyAppWeb.HomeLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="home-container">
    <h1 class="home-title"> Välkommen </h1>

    <div class="home-buttons">
    <.link navigate="/users/log-in" class="home-button home-button-login">
          Logga in
        </.link>

        <.link navigate="/users/register" class="home-button home-button-register">
          Skapa konto
        </.link>

        <a href="/auth/github" class="home-button home-button-github">
          Logga in med GitHub
        </a>
      </div>
    </div>
    """

  end

  end
