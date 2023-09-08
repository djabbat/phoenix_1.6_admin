defmodule SampleAppWeb.ConnTestHelpers do
  alias SampleAppWeb.Router.Helpers, as: Routes
  import Phoenix.ConnTest

  @endpoint SampleAppWeb.Endpoint

  def is_logged_in?(conn) do
    conn.assigns.current_user != nil
  end

  def login_as(conn, user, opts \\ []) do
    %{password: password, remember_me: remember_me} =
      Enum.into(opts, %{password: "password", remember_me: "true"})

    post(
      conn,
      Routes.login_path(conn, :create, %{
        session: %{
          email: user.email,
          password: password,
          remember_me: remember_me
        }
      })
    )
  end
end
