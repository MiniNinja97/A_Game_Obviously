defmodule MyAppWeb.UserLive.Login do
  use MyAppWeb, :live_view



  @impl true
  def render(assigns) do
    ~H"""

      <div class="login-container">
        <div class="text-center">
          <.header>
            <p class="login-title">LOG IN</p>
            <:subtitle >
              <%= if @current_scope do %>
                You need to reauthenticate to perform sensitive actions on your account.
              <% else %>
                Don't have an account? <.link
                  navigate={~p"/users/register"}
                  class=""
                  phx-no-format
                >Sign up</.link>
              <% end %>
            </:subtitle>
          </.header>
        </div>



          <.form
              :let={f}
              for={@form}
              id="login_form_password"
              action={~p"/users/log-in"}
              method="post"
          >
          <.input
            class="email-input"
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label ="Email"
            autocomplete="email"
            required
          />
          <.input
          class="password-input"
            field={@form[:password]}
            type="password"
            label="Password"
            autocomplete="current-password"
          />
          <.button class="login-button">
            LOG IN
          </.button>

        </.form>
      </div>

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form)}

  end




end
