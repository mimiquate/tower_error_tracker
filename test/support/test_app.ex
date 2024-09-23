defmodule TestApp.Repo.Migrations.AddErrorTracker do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(version: 3)

  # We specify `version: 1` in `down`, to ensure we remove all migrations.
  def down, do: ErrorTracker.Migration.down(version: 1)
end

defmodule TestApp.Repo do
  use Ecto.Repo, otp_app: :test_app, adapter: Ecto.Adapters.SQLite3
end
