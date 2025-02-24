defmodule TowerErrorTracker.Reporter do
  @moduledoc false

  def report_event(%Tower.Event{kind: :error, reason: exception, stacktrace: stacktrace} = event) do
    ErrorTracker.report(exception, stacktrace, context(event))

    :ok
  end

  def report_event(%Tower.Event{kind: :throw, reason: value, stacktrace: stacktrace} = event) do
    ErrorTracker.report({:throw, inspect(value)}, stacktrace, context(event))

    :ok
  end

  def report_event(%Tower.Event{kind: :exit, reason: reason, stacktrace: stacktrace} = event) do
    ErrorTracker.report({:exit, Exception.format_exit(reason)}, stacktrace, context(event))

    :ok
  end

  def report_event(
        %Tower.Event{
          kind: :message,
          reason: reason,
          level: level,
          stacktrace: stacktrace,
          log_event: %{meta: %{mfa: {m, f, a}, file: file, line: line}}
        } = event
      )
      when is_nil(stacktrace) or length(stacktrace) == 0 do
    ErrorTracker.report(
      {:message, "[#{level}] #{reason}"},
      [{m, f, a, [file: file, line: line]}],
      context(event)
    )

    :ok
  end

  def report_event(
        %Tower.Event{kind: :message, reason: reason, level: level, stacktrace: stacktrace} = event
      ) do
    ErrorTracker.report({:message, "[#{level}] #{reason}"}, stacktrace || [], context(event))

    :ok
  end

  def report_event(_event) do
    :ignore
  end

  defp context(%{metadata: metadata, plug_conn: plug_conn}) do
    metadata_context(metadata)
    |> Map.merge(request_context(plug_conn))
  end

  defp metadata_context(metadata) when is_map(metadata) and map_size(metadata) > 0 do
    %{metadata: metadata}
  end

  defp metadata_context(_), do: %{}

  if Code.ensure_loaded?(Plug.Conn) do
    defp request_context(%Plug.Conn{} = conn) do
      %{request: request_data(conn)}
    end

    defp request_context(_), do: %{}

    defp request_data(%Plug.Conn{} = conn) do
      %{
        method: conn.method,
        url: "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}"
      }
    end
  else
    defp request_context(_), do: %{}
  end
end
