defmodule SampleAppWeb.UserControllerTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user)}
  end

  test "should get new", %{conn: conn} do
    conn = conn
    |> get(Routes.signup_path(conn, :new))
    assert html_response(conn, 200)
  end

  test "should redirect edit when not logged in",
       %{conn: conn, user: user} do
    conn =
      conn
      |> get(Routes.user_path(conn, :edit, user))

    refute Enum.empty?(get_flash(conn))
    assert redirected_to(conn, 302) == Routes.login_path(conn, :create)
  end

  test "should redirect update when not logged in",
       %{conn: conn, user: user} do
    conn =
      conn
      |> put(
        Routes.user_path(conn, :update, user, %{
          user: %{name: user.name, email: user.email}
        })
      )

    refute Enum.empty?(get_flash(conn))
    assert redirected_to(conn, 302) == Routes.login_path(conn, :create)
  end
end
