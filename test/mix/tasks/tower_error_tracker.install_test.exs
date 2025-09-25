defmodule Mix.Tasks.TowerErrorTracker.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "generates everything from scratch" do
    test_project()
    |> Igniter.compose_task("tower_error_tracker.install", [])
    |> assert_creates(
      "config/config.exs",
      """
      import Config
      config :tower, reporters: [TowerErrorTracker]
      """
    )
  end

  test "is idempotent" do
    test_project()
    |> Igniter.compose_task("tower_error_tracker.install", [])
    |> apply_igniter!()
    |> Igniter.compose_task("tower_error_tracker.install", [])
    |> assert_unchanged()
  end
end
