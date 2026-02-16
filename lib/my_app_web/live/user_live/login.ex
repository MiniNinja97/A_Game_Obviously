defmodule MyAppWeb.UserLive.Login do
  use MyAppWeb, :live_view



  @impl true
  def render(assigns) do
    ~H"""
    <%!-- <Layouts.app flash={@flash} current_scope={@current_scope}> --%>
      <div class="login-container">
        <div class="text-center">
          <.header>
            <p class="login-title">LOG IN</p>
            <:subtitle class="sign-up-link">
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

        <%!-- <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="">the mailbox page</.link>.
            </p>
          </div>
        </div>      --%>

        <%!-- <.form
          :let={f}
          for={@form}
          id="login_form_magic"
          action={~p"/users/log-in"}
          phx-submit="submit_magic"
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="email"
            required
            phx-mounted={JS.focus()}
          />

        </.form>

        <div class="">or</div> --%>

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
          <%!-- <.button class="btn btn-primary w-full" name={@form[:remember_me].name} value="true">
            Log in and stay logged in <span aria-hidden="true">→</span>
          </.button>
          <.button class="btn btn-primary btn-soft w-full mt-2">
            Log in only this time
          </.button> --%>
        </.form>
      </div>
    <%!-- </Layouts.app> --%>
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

  # @impl true
  # def handle_event("submit_password", _params, socket) do
  #   {:noreply, assign(socket, :trigger_submit, true)}
  # end

  # def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
  #   if user = Accounts.get_user_by_email(email) do
  #     Accounts.deliver_login_instructions(
  #       user,
  #       &url(~p"/users/log-in/#{&1}")
  #     )
  #   end

  #   info =
  #     "If your email is in our system, you will receive instructions for logging in shortly."

  #   {:noreply,
  #    socket
  #    |> put_flash(:info, info)
  #    |> push_navigate(to: ~p"/users/log-in")}
  # end


end
