defmodule MyAppWeb.OAuthController do

  use MyAppWeb, :controller

  plug Ueberauth

  alias MyApp.Accounts
  alias MyAppWeb.UserAuth
  def request(conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do

    email = auth.info.email

    case Accounts.get_user_by_email(email) do
      nil -> {:ok, user} =
        Accounts.register_user(%{email: email, password: random_password()})

        UserAuth.log_in_user(conn, user)

        user ->
          UserAuth.log_in_user(conn, user)
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Github-inloggningen misslyckades")
    |> redirect(to: "/")
  end

  defp random_password do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64()
  end
end
