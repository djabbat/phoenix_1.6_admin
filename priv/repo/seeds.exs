# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SampleApp.Repo.insert!(%SampleApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

SampleApp.Repo.insert!(%SampleApp.Accounts.User{
  name: "Example User",
  email: "examplephoenixtutorial@gmail.com",
  password_hash: Argon2.hash_pwd_salt("foobar"),
  admin: true
})

for n <- 1..99 do
  SampleApp.Repo.insert!(%SampleApp.Accounts.User{
    name: Faker.Person.name(),
    email: "example-#{n}@example.com",
    password_hash: Argon2.hash_pwd_salt("foobar")
  })
end
