defmodule Mix.Tasks.TowerErrorTracker.Install.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "Installs TowerErrorTracker"
  end

  @spec example() :: String.t()
  def example do
    "mix tower_error_tracker.install"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    ## Example

    ```sh
    #{example()}
    ```
    """
  end
end

if Code.ensure_loaded?(Igniter) and Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerErrorTracker.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{group: :tower_error_tracker, example: __MODULE__.Docs.example()}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> Tower.Igniter.reporters_list_append(TowerErrorTracker)
    end
  end
else
  defmodule Mix.Tasks.TowerErrorTracker.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    @error_message """
    The task 'tower_error_tracker.install' requires igniter plus tower >= 0.8.4. Please install igniter and/or update tower and try again.

    For more information, see: https://hexdocs.pm/igniter/readme.html#installation
    """

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error(@error_message)
      exit({:shutdown, 1})
    end
  end
end
