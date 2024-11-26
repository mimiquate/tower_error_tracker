defmodule TestApp.Repo.Migrations.AddErrorTracker do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(version: migration_version())

  # We specify `version: 1` in `down`, to ensure we remove all migrations.
  def down, do: ErrorTracker.Migration.down(version: 1)

  defp migration_version do
    Application.spec(:error_tracker, :vsn)
    |> to_string()
    |> Version.parse!()
    |> Version.match?(">= 0.5.0")
    |> case do
      true -> 4
      false -> 3
    end
  end
end

defmodule TestApp.Repo do
  use Ecto.Repo, otp_app: :test_app, adapter: Ecto.Adapters.SQLite3
end
