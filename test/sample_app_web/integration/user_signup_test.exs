defmodule SampleAppWeb.UserSignupTest do
  use SampleAppWeb.ConnCase, async: true

  test "invalid signup information", %{conn: conn} do
    user_records_before = Repo.one(from u in User, select: count())

    conn

    |> get(Routes.signup_path(conn, :new))
    |> post(Routes.user_path(conn, :create), %{user: %{
      name: "",
      email: "user@invalid",
      password: "foo",
      password_confirmation: "bar"}})

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after
    end

    test "valid signup information", %{conn: conn} do
      user_email = "user@example.com"
      user_records_before = Repo.one(from u in User, select: count())

      conn =
        conn
        |> get(Routes.signup_path(conn, :new))
        |> post(Routes.signup_path(conn, :create), %{
          user: %{
            name: "Example User",
            email: "user@example.com",
            password: "password",
            password_confirmation: "password"
          }
        })

      user_records_after = Repo.one(from u in User, select: count())
      assert user_records_before + 1 == user_records_after
      user = Repo.get_by(User, email: user_email)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      assert is_logged_in?(conn)
    end
end
