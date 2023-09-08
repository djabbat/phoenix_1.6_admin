defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleAppWeb.AuthPlug

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{
        "session" => %{
          "email" => email,
          "password" => pass,
          "remember_me" => remember_me
        }
      }) do
    case Accounts.authenticate_by_email_and_pass(
           String.downcase(email),
           pass
         ) do
      {:ok, user} ->
        conn = AuthPlug.login(conn, user)

        conn =
          if String.to_atom(remember_me) do
            AuthPlug.remember(conn, user)
          else
            delete_resp_cookie(conn, "remember_token")
          end

          AuthPlug.redirect_back_or(conn, Routes.user_path(conn, :show, user))

      # Log the user in and redirect to the user's show page.
      {:error, _reason} ->
        conn
        # Create an error message.
        |> put_flash(:danger, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> redirect(to: Routes.root_path(conn, :home))
  end
end
