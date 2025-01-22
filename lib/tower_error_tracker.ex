defmodule TowerErrorTracker do
  @moduledoc """
  The module that needs to be added to the list of Tower reporters.

  ## Example

      config :tower, :reporters, [TowerErrorTracker]
  """

  @behaviour Tower.Reporter

  @impl true
  def report_event(event) do
    value = Process.get(:error_tracker_context, %{})

    Tower.async(fn ->
      Process.put(:error_tracker_context, value)

      TowerErrorTracker.Reporter.report_event(event)
    end)
  end
end
