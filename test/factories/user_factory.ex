defmodule SampleApp.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %SampleApp.Accounts.User{
          name: sequence(:name, &"Example User#{&1}"),
          email: sequence(:email, &"user-#{&1}@example.com"),
          password: "password",
          password_confirmation: "password",
          password_hash: Argon2.hash_pwd_salt("password"),
          admin: false
        }
      end
    end
  end
end
