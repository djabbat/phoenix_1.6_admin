defmodule SampleAppWeb.UserControllerTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user), other_user: Factory.insert(:user)}
  end

  test "should redirect index when not logged in", %{conn: conn} do
    conn =
      conn
      |> get(Routes.user_path(conn, :index))

    refute Enum.empty?(get_flash(conn))
    assert redirected_to(conn, 302) == Routes.login_path(conn, :create)
  end

  test "should get new", %{conn: conn} do
    conn = conn
    |> get(Routes.signup_path(conn, :new))
    assert html_response(conn, 200)
  end

  test "should redirect edit when logged in as wrong user",
       %{conn: conn, user: user, other_user: other_user} do
    conn =
      conn
      |> login_as(other_user)
      |> get(Routes.user_path(conn, :edit, user))

    assert Enum.empty?(get_flash(conn))
    assert redirected_to(conn, 302) == Routes.root_path(conn, :home)
  end

  test "should redirect update when logged in as wrong user",
       %{conn: conn, user: user, other_user: other_user} do
    conn =
      conn
      |> login_as(other_user)
      |> put(
        Routes.user_path(conn, :update, user, %{
          user: %{name: user.name, email: user.email}
        })
      )

    assert Enum.empty?(get_flash(conn))
    assert redirected_to(conn, 302) == Routes.root_path(conn, :home)
  end

  test "should redirect delete when not logged in",
       %{conn: conn, user: user} do
    user_records_before = Repo.one(from u in User, select: count())
    conn = delete(conn, Routes.user_path(conn, :delete, user))
    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after
    assert redirected_to(conn, 302) == Routes.login_path(conn, :create)
  end

  test "should redirect delete when logged in as a non-admin",
       %{conn: conn, user: user, other_user: other_user} do
    user_records_before = Repo.one(from u in User, select: count())

    conn =
      conn
      |> login_as(other_user)
      |> delete(Routes.user_path(conn, :delete, user))

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after
    assert redirected_to(conn, 302) == Routes.root_path(conn, :home)
  end
end
