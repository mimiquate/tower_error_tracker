defmodule TowerErrorTracker.ErrorTestPlug do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/arithmetic-error" do
    ErrorTracker.set_context(%{user_id: 123})

    1 / 0

    send_resp(conn, 200, "OK")
  end

  get "/uncaught-throw" do
    throw("from inside a plug")

    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
