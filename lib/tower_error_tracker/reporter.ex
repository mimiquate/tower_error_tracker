defmodule TowerErrorTracker.Reporter do
  @moduledoc """
  The reporter module that needs to be added to the list of Tower reporters.

  ## Example

      config :tower, :reporters, [TowerErroTracker.Reporter]
  """

  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{kind: :error, reason: exception, stacktrace: stacktrace}) do
    ErrorTracker.report(exception, stacktrace)
  end

  def report_event(_event) do
    :ignore
  end
end
