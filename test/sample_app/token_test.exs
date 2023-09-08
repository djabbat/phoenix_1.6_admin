defmodule SampleApp.TokenTest do
  use SampleApp.DataCase
  alias SampleApp.Accounts.User

  test "gen_remember_token/1 and verify_remember_token/1 sign and
        verify token with user id" do
    id = 3
    token = SampleApp.Token.gen_remember_token(%User{id: id})
    assert SampleApp.Token.verify_remember_token(token) == {:ok, id}
  end
end
