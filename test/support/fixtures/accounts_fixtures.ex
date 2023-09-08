defmodule SampleApp.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SampleApp.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name"
      })
      |> SampleApp.Accounts.create_user()

    user
  end
end
