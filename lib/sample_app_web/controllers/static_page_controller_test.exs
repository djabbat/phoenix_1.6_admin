defmodule SampleAppWeb.StaticPageControllerTest do
  use SampleAppWeb.ConnCase

  test "should get home", %{conn: conn} do
    conn =
      conn
      |> get(Routes.root_path(conn, :home))

    html_response(conn, )
    |> assert_select("title", "Home | Phoenix Tutorial Sample App")
  end

  test "should get help", %{conn: conn} do
    conn =
      conn
      |> get(Routes.help_path(conn, :help))

    html_response(conn, 200)
    |> assert_select("title", "Help | Phoenix Tutorial Sample App")
  end

  test "should get about", %{conn: conn} do
    conn =
      conn
      |> get(Routes.about_path(conn, :about))

    html_response(conn, 200)
    |> assert_select("title", "About | Phoenix Tutorial Sample App")
  end

  test "should get contact", %{conn: conn} do
    conn =
      conn
      |> get(Routes.contact_path(conn, :contact))

    html_response(conn, 200)
    |> assert_select("title", "Contact | Phoenix Tutorial Sample App")
  end
end
