defmodule SampleAppWeb.UserEditTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user)}
  end

  test "unsuccessful edit", %{conn: conn, user: user} do
    conn =
      conn
      |> login_as(user)
      |> get(Routes.user_path(conn, :edit, user))

    html_response(conn, 200)
    |> assert_select("form[action='#{Routes.user_path(conn, :update, user)}']")

    conn =
      put(conn, Routes.user_path(conn, :update, user), %{
        user: %{
          name: "",
          email: "foo@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      })

    html_response(conn, 200)
    |> assert_select("form[action='#{Routes.user_path(conn, :update, user)}']")
  end

  test "successful edit", %{conn: conn, user: user} do
    name = "Foo Bar"
    email = "foo@bar.com"

    conn =
      conn
      |> login_as(user)
      |> get(Routes.user_path(conn, :edit, user))

    html_response(conn, 200)
    |> assert_select("form[action='#{Routes.user_path(conn, :update, user)}']")

    conn =
      put(conn, Routes.user_path(conn, :update, user), %{
        user: %{
          name: name,
          email: email,
          password: "",
          password_confirmation: ""
        }
      })

    refute Enum.empty?(get_flash(conn))
    assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    updated_user = Accounts.get_user(user.id)
    assert updated_user.name == name
    assert updated_user.email == email
  end

  test "successful edit with friendly forwarding", %{conn: conn, user: user} do
    name = "Foo Bar"
    email = "foo@bar.com"

    conn =
      conn
      |> get(Routes.user_path(conn, :edit, user))
      |> login_as(user)

    assert redirected_to(conn) == Routes.user_path(conn, :edit, user)

    conn =
      put(conn, Routes.user_path(conn, :update, user), %{
        user: %{
          name: name,
          email: email,
          password: "",
          password_confirmation: ""
        }
      })

    refute Enum.empty?(get_flash(conn))
    assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    updated_user = Accounts.get_user(user.id)
    assert updated_user.name == name
    assert updated_user.email == email
  end
end
