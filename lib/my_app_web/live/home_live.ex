defmodule MyAppWeb.HomeLive do
  use MyAppWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="home-container">
    <h1 class="home-title"> A game obviously... </h1>

    <div class="home-buttons">
    <.link navigate="/users/log-in" class="home-button home-button-login">
          LOG IN
        </.link>

        <.link navigate="/users/register" class="home-button home-button-register">
          REGISTER
        </.link>

        <a href="/auth/github" class="home-button home-button-github">
          LOG IN WITH GITHUB
        </a>
      </div>
    </div>
    """

  end

  end
