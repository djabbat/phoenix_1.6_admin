defmodule SampleAppWeb.AuthPlugTest do
  use SampleAppWeb.ConnCase
  alias SampleAppWeb.AuthPlug

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(SampleAppWeb.Router, :browser)
      |> get("/")

    {:ok, conn: conn}
  end

  describe "remember/2" do
    test "puts the remember_token cookie encrypted with user id",
    %{conn: conn} do
      remember_conn =
        conn
        |> AuthPlug.remember(%User{id: 5})
        |> send_resp(:ok, "")

      token = remember_conn.cookies["remember_token"]
      {:ok, user_id} = SampleApp.Token.verify_remember_token(token)
      assert user_id == 5
    end
  end

  describe "call/2" do
    test "places user from session into assigns as current_user",
         %{conn: conn} do
      user = Factory.insert(:user)

      conn =
        conn
        |> put_session(:user_id, user.id)
        |> AuthPlug.call(AuthPlug.init([]))

      assert conn.assigns.current_user.id == user.id
    end

    test "with no session sets current_user assign to nil",
         %{conn: conn} do
      conn = AuthPlug.call(conn, AuthPlug.init([]))
      assert conn.assigns.current_user == nil
    end

        test "with valid remember_token cookie and no session
          sets current_user assign",
         %{conn: conn} do
      user = Factory.insert(:user)
      token = SampleApp.Token.gen_remember_token(user)

      conn =
        conn
        |> put_resp_cookie("remember_token", token, max_age: 86400)
        |> AuthPlug.call(AuthPlug.init([]))

      assert conn.assigns.current_user.id == user.id
    end

    test "with valid remember_token cookie with invalid user id and
          no session sets current_user assign to nil and
          deletes remember_token cookie",
         %{conn: conn} do
      bad_user_id = 123
      token = SampleApp.Token.gen_remember_token(%User{id: bad_user_id})

      conn =
        conn
        |> put_resp_cookie("remember_token", token, max_age: 86400)
        |> AuthPlug.call(AuthPlug.init([]))

      assert conn.assigns.current_user == nil
      assert conn.cookies["remember_token"] == nil
    end

    test "with invalid remember_token and no session
          deletes remember_token cookie",
         %{conn: conn} do
      token = "badtoken"

      conn =
        conn
        |> put_resp_cookie("remember_token", token, max_age: 86400)
        |> AuthPlug.call(AuthPlug.init([]))

      assert conn.assigns.current_user == nil
      assert conn.cookies["remember_token"] == nil
    end
  end

  describe "login/2" do
    test "puts the user id in the session", %{conn: conn} do
      login_conn =
        conn
        |> AuthPlug.login(%User{id: 5})
        |> send_resp(:ok, "")

      next_conn = get(login_conn, "/")
      assert get_session(next_conn, :user_id) == 5
    end
  end

  describe "logout/1" do
    test "drops the session", %{conn: conn} do
      logout_conn =
        conn
        |> put_session(:user_id, 5)
        |> AuthPlug.logout()
        |> send_resp(:ok, "")

      next_conn = get(logout_conn, "/")
      refute get_session(next_conn, :user_id)
    end

    test "deletes remember_token cookie", %{conn: conn} do
      user_id = 5
      token = Phoenix.Token.sign(conn, "test cookie", user_id)

      logout_conn =
        conn
        |> put_resp_cookie("remember_token", token, max_age: 86400)
        |> AuthPlug.logout()
        |> send_resp(:ok, "")

      assert logout_conn.cookies["remember_token"] == nil
    end
  end
end
