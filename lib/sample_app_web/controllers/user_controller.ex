defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  plug :logged_in_user when action in [:index, :edit, :update, :delete]
  plug :correct_user   when action in [:edit, :update]
  plug :admin_user     when action in [:delete]

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> AuthPlug.login(user)
        |> put_flash(:success, "Welcome to the Sample App!")
        |> redirect(to: Routes.user_path(conn, :show, user))

      # Handle a successful User insertion.
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user, title: user.name)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Profile updated")
        |> redirect(to: Routes.user_path(conn, :show, user))

      # Handle a successful update.
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def index(conn, params) do
    users_page = Accounts.paginate_users(params)
    render(conn, "index.html", users_page: users_page)
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    Accounts.delete_user(user)
    conn

    |> put_flash(:success, "User deleted")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
