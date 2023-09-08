defmodule SampleApp.Factory do
  use ExMachina.Ecto, repo: SampleApp.Repo
  use SampleApp.UserFactory
end
