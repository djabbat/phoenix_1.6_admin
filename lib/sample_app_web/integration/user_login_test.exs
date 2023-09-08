defmodule SampleAppWeb.UserLoginTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user)}
  end

  test "login with valid information", %{conn: conn, user: user} do
    conn =
      conn
      |> get(Routes.login_path(conn, :new))
      |> post(Routes.login_path(conn, :create), %{
        session: %{
          email: user.email,
          password: "password"
        }
      })

    assert is_logged_in?(conn)

    assert redir_path =
             redirected_to(conn) ==
               Routes.user_path(conn, :show, user)

    conn = get(recycle(conn), redir_path)

    html_response(conn, 200)
    |> refute_select("a[href='#{Routes.login_path(conn, :new)}']")
    |> assert_select("a[href='#{Routes.logout_path(conn, :delete)}']")
    |> assert_select("a[href='#{Routes.user_path(conn, :show, user)}']")
  end
end
