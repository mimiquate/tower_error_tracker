defmodule TowerErrorTrackerTest do
  use ExUnit.Case
  doctest TowerErrorTracker

  use AssertEventually, timeout: 100, interval: 10

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    Application.put_env(:error_tracker, :repo, TestApp.Repo)
    Application.put_env(:error_tracker, :otp_app, :tower_error_tracker)

    start_link_supervised!({
      TestApp.Repo,
      database: "tmp/test-#{:rand.uniform(10_000)}.db", journal_mode: :memory
    })

    capture_log(fn ->
      Ecto.Migrator.up(TestApp.Repo, 0, TestApp.Repo.Migrations.AddErrorTracker)
    end)

    Application.put_env(:tower, :reporters, [TowerErrorTracker.Reporter])
    Tower.attach()

    on_exit(fn ->
      Tower.detach()
      Application.put_env(:tower, :reporters, [])
      Application.put_env(:error_tracker, :otp_app, nil)
      Application.put_env(:error_tracker, :repo, nil)
    end)
  end

  test "reports arithmetic error" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        1 / 0
      end)
    end)

    assert_eventually(
      [
        %{
          kind: "Elixir.ArithmeticError",
          reason: "bad argument in arithmetic expression",
          occurrences: [_]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
