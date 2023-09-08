defmodule SampleAppWeb.UserIndexTest do
  use SampleAppWeb.ConnCase, async: true

  setup do
    admin = Factory.insert(:user, admin: true)
    non_admin = Factory.insert(:user)
    {:ok, admin: admin, non_admin: non_admin}
  end

  test "index as admin including pagination and delete links",
       %{conn: conn, admin: admin, non_admin: non_admin} do
    for _n <- 1..31 do
      Factory.insert(:user)
    end

    conn =
      conn
      |> login_as(admin)
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

      unless user.id == admin.id do
        delete_user_path = Routes.user_path(conn, :delete, user)

        html
        |> assert_select(
          "a[data-method='delete'][href='#{delete_user_path}']",
          text: "delete"
        )
      end
    end

    user_records_before = Repo.one(from u in User, select: count())
    delete(conn, Routes.user_path(conn, :delete, non_admin))
    user_records_after = Repo.one(from u in User, select: count())
    assert user_records_before == user_records_after + 1
  end

  test "index as non-admin", %{conn: conn, non_admin: non_admin} do
    conn =
      conn
      |> login_as(non_admin)
      |> get(Routes.user_path(conn, :index))

    html_response(conn, 200)
    |> refute_select("a[data-method='delete']", text: "delete")
  end
end
