defmodule SampleApp.AccountsTest do
  use SampleApp.DataCase, async: true
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleApp.Factory

  @valid_attrs %{
    name: "Example User",
    email: "user@example.com",
    password: "foobar",
    password_confirmation: "foobar"
  }

  test "delete_user/1 deletes the user" do
    user = Factory.insert(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert Accounts.get_user(user.id) == nil
  end

  describe "get_user/1" do
    test "returns the user with given id" do
      %User{id: id} = Factory.insert(:user)
      assert %User{id: ^id} = Accounts.get_user(id)
    end

    test "returns nil if the user is not found" do
      invalid_user_id = 111
      assert nil == Accounts.get_user(invalid_user_id)
    end
  end

  describe "get_user!/1" do
    test "returns the user with given id" do
      %User{id: id} = Factory.insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(id)
    end

    test "raises Ecto.NoResultsError if the user is not found" do
      invalid_user_id = 111

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(invalid_user_id)
      end
    end
  end

  describe "get_user_by/1" do
    test "returns the user with given email field" do
      %User{email: email} = Factory.insert(:user)
      assert %User{email: ^email} = Accounts.get_user_by(email: email)
    end

    test "returns nil if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"

      assert nil ==
               Accounts.get_user_by(email: invalid_user_email)
    end
  end

  describe "get_user_by!/1" do
    test "returns the user with given email field" do
      %User{email: email} = Factory.insert(:user)
      assert %User{email: ^email} = Accounts.get_user_by!(email: email)
    end

    test "raises Ecto.NoResultsError if the user is not found" do
      invalid_user_email = "doesnotexist@example.com"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by!(email: invalid_user_email)
      end
    end
  end

  test "list_users/0 returns all users" do
    %User{id: id1} = Factory.insert(:user)
    %User{id: id2} = Factory.insert(:user)
    assert [%User{id: ^id1}, %User{id: ^id2}] = Accounts.list_users()
  end

  describe "create_user/1" do
    test "with valid attributes inserts user" do
      assert {:ok, %User{} = _user} = Accounts.create_user(@valid_attrs)
    end

    test "name left blank does not insert user" do
      assert {:error, %Ecto.Changeset{}} = Accounts
      .create_user(%{@valid_attrs | name: "      "})
    end

    test "email left blank does not insert user" do
      assert {:error, %Ecto.Changeset{}} = Accounts
      .create_user(%{@valid_attrs | email: "      "})
    end

    test "name too long does not insert user" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{@valid_attrs
               | name: String.duplicate("a", 51)})
    end

    test "email too long does not insert user" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | email: String.duplicate("a", 244) <> "@example.com"
               })
    end

    test "valid email addresses insert user" do
      valid_addresses = ["user@example.com", "USER@foo.COM",
        "A_US-ER@foo.bar.org", "first.last@foo.jp", "alice+bob@baz.cn"]

      for valid_address <- valid_addresses do
        assert {:ok, %User{}} =
                 Accounts.create_user(%{
                   @valid_attrs
                   | email: valid_address
                 })
      end
    end

    test "invalid email addresses do not insert user" do
      invalid_addresses = ["user@example,com",
        "user_at_foo.org", "user.name@example.",
        "foo@bar_baz.com", "foo@bar+baz.com"]

      for invalid_address <- invalid_addresses do
        assert {:error, %Ecto.Changeset{}} =
                 Accounts.create_user(%{
                   @valid_attrs
                   | email: invalid_address
                 })
      end
    end

    test "existing email address does not insert user" do
      Factory.insert(:user, @valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | email: String.upcase(@valid_attrs.email)
               })
    end

    test "password left blank does not insert user" do
      blank_password = String.duplicate(" ", 6)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | password: blank_password,
                   password_confirmation: blank_password
               })
    end

    test "password too short does not insert user" do
      short_password = String.duplicate("a", 5)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{
                 @valid_attrs
                 | password: short_password,
                   password_confirmation: short_password
               })
    end
  end



  describe "authenticate_by_email_and_pass/2" do
    @email "user@example.com"
    @pass "123456"

    setup do
      {:ok,
       user:
         Factory.insert(:user,
           email: @email,
           password: @pass,
           password_hash: Argon2.hash_pwd_salt(@pass)
         )}
    end

    test "returns user with correct password", %{user: %User{id: id}} do
      assert {:ok, %User{id: ^id}} = Accounts
      .authenticate_by_email_and_pass(@email, @pass)
    end

    test "returns unauthorized error with invalid password" do
      assert {:error, :unauthorized} = Accounts
      .authenticate_by_email_and_pass(@email, "badpass")
    end

    test "returns not found error with no matching user for email" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_email_and_pass("bad@email.com", @pass)
    end
  end

  describe "update_user/2" do
    setup do
      {:ok, user: Factory.insert(:user)}
    end

    test "name left blank does not update user", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | name: "      "
               })
    end

    test "email left blank does not update user", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | email: "      "
               })
    end

    test "name too long does not update user", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | name: String.duplicate("a", 51)
               })
    end

    test "email too long does not update user", %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | email: String.duplicate("a", 244) <> "@example.com"
               })
    end

    test "valid email addresses update user", %{user: user} do
      valid_addresses = ~w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn)

      for valid_address <- valid_addresses do
        assert {:ok, %User{}} =
                 Accounts.update_user(user, %{
                   @valid_attrs
                   | email: valid_address
                 })
      end
    end

    test "invalid email addresses do not update user", %{user: user} do
      invalid_addresses = ~w(user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com)

      for invalid_address <- invalid_addresses do
        assert {:error, %Ecto.Changeset{}} =
                 Accounts.update_user(user, %{
                   @valid_attrs
                   | email: invalid_address
                 })
      end
    end

    test "existing email address does not update user", %{user: user} do
      other_user = Factory.insert(:user)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | email: String.upcase(other_user.email)
               })
    end

    test "email address is updated as lower-case", %{user: user} do
      mixed_case_email = "Foo@ExAMPle.CoM"

      assert {:ok, %User{email: "foo@example.com"}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | email: mixed_case_email
               })
    end



    test "password and password confirmation blank with
          no characters does update user",
         %{user: user} do
      assert {:ok, %User{} = updated_user} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | email: user.email,
                   password: "",
                   password_confirmation: ""
               })

      assert {:ok, %User{}} =
               Accounts.authenticate_by_email_and_pass(
                 updated_user.email,
                 user.password
               )
    end

    test "password and password confirmation unmatched
          does not update user",
         %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | password: "password",
                   password_confirmation: "diffpassword"
               })
    end

    test "password too short does not update user", %{user: user} do
      short_password = String.duplicate("a", 5)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{
                 @valid_attrs
                 | password: short_password,
                   password_confirmation: short_password
               })
    end
  end
end
