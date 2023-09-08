defmodule SampleAppWeb.SessionControllerTest do
  use SampleAppWeb.ConnCase, async: true

  test "should get new", %{conn: conn} do
    conn =
      conn
      |> get(Routes.login_path(conn, :new))

    html_response(conn, 200)
    |> assert_select("title", "Log in | Phoenix Tutorial Sample App")
  end
end
