defmodule TowerErrorTrackerTest do
  use ExUnit.Case
  doctest TowerErrorTracker

  use AssertEventually, timeout: 100, interval: 10

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    Path.wildcard("tmp/test-*.db")
    |> Enum.map(&File.rm!/1)

    put_env(:error_tracker, :repo, TestApp.Repo)
    put_env(:error_tracker, :otp_app, :tower_error_tracker)

    start_link_supervised!({
      TestApp.Repo,
      database: "tmp/test-#{:rand.uniform(10_000)}.db", journal_mode: :memory
    })

    capture_log(fn ->
      Ecto.Migrator.up(TestApp.Repo, 0, TestApp.Repo.Migrations.AddErrorTracker)
    end)

    put_env(:tower, :reporters, [TowerErrorTracker])
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

  test "reports an uncaught throw" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        throw("something")
      end)
    end)

    assert_eventually(
      [
        %{
          kind: "throw",
          reason: "\"something\"",
          occurrences: [_]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "reports an abnormal exit" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit(:abnormal)
      end)
    end)

    assert_eventually(
      [
        %{
          kind: "exit",
          reason: ":abnormal",
          occurrences: [_]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "reports a :gen_server common abnormal exit" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit({:bad_return_value, "bad value"})
      end)
    end)

    assert_eventually(
      [
        %{
          kind: "exit",
          reason: "bad return value: \"bad value\"",
          occurrences: [_]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "includes exception request data if available with Plug.Cowboy" do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    start_supervised!(
      {Plug.Cowboy, plug: TowerErrorTracker.ErrorTestPlug, scheme: :http, port: plug_port}
    )

    capture_log(fn ->
      {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
    end)

    assert_eventually(
      [
        %{
          kind: "Elixir.ArithmeticError",
          reason: "bad argument in arithmetic expression",
          occurrences: [
            %{
              context: %{
                "request" => %{
                  "method" => "GET",
                  "url" => ^url
                }
              }
            }
          ]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "includes exception request data if available with Bandit" do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    capture_log(fn ->
      start_supervised!(
        {Bandit, plug: TowerErrorTracker.ErrorTestPlug, scheme: :http, port: plug_port}
      )

      {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
    end)

    assert_eventually(
      [
        %{
          kind: "Elixir.ArithmeticError",
          reason: "bad argument in arithmetic expression",
          occurrences: [
            %{
              context: %{
                "request" => %{
                  "method" => "GET",
                  "url" => ^url
                },
                "user_id" => 123
              }
            }
          ]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "reports throw with Bandit" do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    capture_log(fn ->
      start_supervised!(
        {Bandit, plug: TowerErrorTracker.ErrorTestPlug, scheme: :http, port: plug_port}
      )

      {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
    end)

    assert_eventually(
      [
        %{
          kind: "throw",
          reason: "\"from inside a plug\"",
          occurrences: [
            %{
              context: %{
                "request" => %{
                  "method" => "GET",
                  "url" => ^url
                }
              }
            }
          ]
        }
      ] = TestApp.Repo.all(ErrorTracker.Error) |> TestApp.Repo.preload(:occurrences)
    )
  end

  test "reports event metadata as context" do
    Tower.report_exception(RuntimeError.exception("Oops!"), [], metadata: %{user_id: 123})

    assert_eventually(
      [
        %{
          kind: "Elixir.RuntimeError",
          reason: "Oops!",
          occurrences: [
            %{
              context: %{
                "metadata" => %{
                  "user_id" => 123
                }
              }
            }
          ]
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

  defp put_env(app, key, value) do
    original_value = Application.get_env(app, key)
    Application.put_env(app, key, value)

    on_exit(fn ->
      if original_value == nil do
        Application.delete_env(app, key)
      else
        Application.put_env(app, key, original_value)
      end
    end)
  end
end
