defmodule TowerErrorTracker.Reporter do
  @moduledoc """
  The reporter module that needs to be added to the list of Tower reporters.

  ## Example

      config :tower, :reporters, [TowerErroTracker.Reporter]
  """

  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{
        kind: :error,
        reason: exception,
        stacktrace: stacktrace,
        plug_conn: plug_conn
      }) do
    ErrorTracker.report(exception, stacktrace, context(plug_conn))

    :ok
  end

  def report_event(%Tower.Event{
        kind: kind,
        reason: reason,
        stacktrace: stacktrace,
        plug_conn: plug_conn
      })
      when kind in [:throw, :exit] do
    ErrorTracker.report({kind, reason}, stacktrace, context(plug_conn))

    :ok
  end

  def report_event(_event) do
    :ignore
  end

  if Code.ensure_loaded?(Plug.Conn) do
    defp context(%Plug.Conn{} = conn) do
      %{request: request_data(conn)}
    end

    defp context(_), do: %{}

    defp request_data(%Plug.Conn{} = conn) do
      %{
        method: conn.method,
        url: "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}"
      }
    end
  else
    defp context(_), do: %{}
  end
end
