defmodule TowerErrorTracker.ErrorTestPlug do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/arithmetic-error" do
    1 / 0

    send_resp(conn, 200, "OK")
  end
end
