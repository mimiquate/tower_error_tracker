defmodule TowerErrorTracker do
  @moduledoc """
  The module that needs to be added to the list of Tower reporters.

  ## Example

      config :tower, :reporters, [TowerErrorTracker]
  """

  @behaviour Tower.Reporter

  @impl true
  def report_event(event) do
    TowerErrorTracker.Reporter.report_event(event)
  end
end
