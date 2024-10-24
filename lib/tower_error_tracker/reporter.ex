defmodule TowerErrorTracker.Reporter do
  @moduledoc false

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
        kind: :throw,
        reason: reason,
        stacktrace: stacktrace,
        plug_conn: plug_conn
      }) do
    ErrorTracker.report({:throw, reason}, stacktrace, context(plug_conn))

    :ok
  end

  def report_event(%Tower.Event{
        kind: :exit,
        reason: reason,
        stacktrace: stacktrace,
        plug_conn: plug_conn
      }) do
    ErrorTracker.report({:exit, Exception.format_exit(reason)}, stacktrace, context(plug_conn))

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
