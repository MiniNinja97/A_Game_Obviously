defmodule MyAppWeb.HomeLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="home-container">
    <h1 class="home-title"> Välkommen </h1>

    <div class="home-buttons">
    <.link patch="/users/log-in" class="home-button home-button-login">
          Logga in
        </.link>

        <.link patch="/users/register" class="home-button home-button-register">
          Skapa konto
        </.link>

        <.link href="/github" class="home-button home-button-github">
          Logga in med GitHub
        </.link>
      </div>
    </div>
    """

  end

  end
