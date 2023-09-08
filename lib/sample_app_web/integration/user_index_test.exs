defmodule SampleAppWeb.UserIndexTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    {:ok, user: Factory.insert(:user)}
  end

  test "index including pagination",
       %{conn: conn, user: user} do
    for _n <- 1..31 do
      Factory.insert(:user)
    end

    conn =
      conn
      |> login_as(user)
      |> get(Routes.user_path(conn, :index))

    html =
      html_response(conn, 200)
      |> assert_select("ul.pagination", count: 2)

    first_page_of_users = Accounts.paginate_users(%{page: 1})

    for user <- first_page_of_users do
      html
      |> assert_select(
        "ul.users a[href='#{Routes.user_path(conn, :show, user)}']",
        match: user.name
      )
    end
  end
end
