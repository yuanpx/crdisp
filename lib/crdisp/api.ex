defmodule Api do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Api, []
  end

  get "/" do
    conn
    |> send_resp(200, "ok")
    |> halt
  end
end
