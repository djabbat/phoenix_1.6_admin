defmodule SampleApp.Token do
  alias SampleApp.Accounts.User

  @remember_salt "remember-user-salt"

  def gen_remember_token(%User{id: user_id}) do
    Phoenix.Token.sign(SampleAppWeb.Endpoint, @remember_salt, user_id)
  end

  def verify_remember_token(token) do
    Phoenix.Token.verify(SampleAppWeb.Endpoint, @remember_salt, token,
    max_age: :infinity)
  end
end
