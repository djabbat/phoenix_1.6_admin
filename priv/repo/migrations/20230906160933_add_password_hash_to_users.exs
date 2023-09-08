defmodule SampleApp.Repo.Migrations.AddPasswordHashToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string, default: "", null: false
    end
  end
end
