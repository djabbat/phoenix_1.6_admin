defmodule SampleAppWeb.AuthPlug do
  import Plug.Conn
  alias SampleApp.Accounts
  import Phoenix.Controller
  alias SampleAppWeb.Router.Helpers, as: Routes

  @cookie_max_age 630720000 # 20 years in seconds

  def init(opts), do: opts

  # Function plug that confirms an admin user.
  def admin_user(conn, _opts) do
    unless conn.assigns.current_user.admin do
      conn
      |> redirect(to: Routes.root_path(conn, :home))
      |> halt()
    else
      conn
    end
  end

  def call(conn, _opts) do
    cond do
      conn.assigns[:current_user] ->
        conn

      user_id = get_session(conn, :user_id) ->
        assign(conn, :current_user, Accounts.get_user(user_id))

      token = conn.cookies["remember_token"] ->
        case SampleApp.Token.verify_remember_token(token) do
          {:ok, user_id} ->
            if user = Accounts.get_user(user_id) do
              login(conn, user)
            else
              logout(conn)
            end

          {:error, _reason} ->
            logout(conn)
        end

      true ->
        assign(conn, :current_user, nil)
    end
  end

  # Function plug that confirms a logged-in user
  def logged_in_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> store_location()
      |> put_flash(:danger, "Please log in.")
      |> redirect(to: Routes.login_path(conn, :create))
      |> halt()
    end
  end

  # Logs in the given user.
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  # Remembers a user in a persistent session.
  def remember(conn, user) do
    token = SampleApp.Token.gen_remember_token(user)
    put_resp_cookie(conn, "remember_token", token, max_age: @cookie_max_age)
  end

  # Logs out the current user.
  def logout(conn) do
    conn
    |> delete_resp_cookie("remember_token")
    |> configure_session(drop: true)
    |> assign(:current_user, nil)
  end

  # Function plug that confirms the correct user.
  def correct_user(conn, _opts) do
    user_id = String.to_integer(conn.params["id"])

    unless user_id == conn.assigns.current_user.id do
      conn
      |> redirect(to: Routes.root_path(conn, :home))
      |> halt()
    else
      conn
    end
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(conn, default) do
    path = get_session(conn, :forwarding_url) || default

    conn
    |> delete_session(:forwarding_url)
    |> redirect(to: path)
  end

  # Stores the URL trying to be accessed.
  def store_location(conn) do
    case conn do
      %Plug.Conn{method: "GET"} ->
        put_session(conn, :forwarding_url, conn.request_path)

      _ ->
        conn
    end
  end
end
