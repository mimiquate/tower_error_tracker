defmodule TestApp.Repo.Migrations.AddErrorTracker do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(version: migration_version())

  # We specify `version: 1` in `down`, to ensure we remove all migrations.
  def down, do: ErrorTracker.Migration.down(version: 1)

  defp migration_version do
    error_tracker_version =
      Application.spec(:error_tracker, :vsn)
      |> to_string()
      |> Version.parse!()

    cond do
      Version.match?(error_tracker_version, ">= 0.6.0") -> 5
      Version.match?(error_tracker_version, "~> 0.5.0") -> 4
      true -> 3
    end
  end
end

defmodule TestApp.Repo do
  use Ecto.Repo, otp_app: :test_app, adapter: Ecto.Adapters.SQLite3
end
