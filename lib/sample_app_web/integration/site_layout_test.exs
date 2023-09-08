defmodule SampleAppWeb.UserSignupTest do
  use SampleAppWeb.ConnCase, async: true

  test "invalid signup information", %{conn: conn} do
    user_records_before = Repo.one(from u in User, select: count())

    conn
    |> get(Routes.signup_path(conn, :new))
    |> post(Routes.user_path(conn, :create), %{
      user: %{
        name: "",
        email: "user@invalid",
        password: "foo",
        password_confirmation: "bar"
      }
    })

    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after
  end
end
