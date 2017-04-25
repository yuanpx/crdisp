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

  def resp_data(data) do
    out = %{
      "ret" => 0,
      "msg" => data
    }
    Poison.Encoder.encode(out, [])
  end

  def resp_error(error) do
    out = %{
      "ret" => -1,
      "msg" => error
    }

    Poison.Encoder.encode(out, [])
  end

  get "/" do
    conn
    |> send_resp(200, "ok")
    |> halt
  end

  get "/test" do
    conn = fetch_query_params(conn)
    query_string_map = conn.query_params
    conn
    |> send_resp(200, Poison.Encoder.encode(query_string_map, []))
    |> halt
  end

  get "/node" do
    nodes = DB.get_all_node()
    res = for node_info <- nodes do
      %{
        "host" => node_info["host"],
        "api" => node_info["api"],
        "type" => node_info["type"]
      }
    end
    conn
    |> send_resp(200, resp_data(res))
    |> halt
  end

  get "/api/node/add" do
    conn = fetch_query_params(conn)
    query_string_map = conn.query_params
    host = query_string_map["host"]
    api = query_string_map["api"]
    type = query_string_map["type"]
    if host == nil || api == nil || type == nil  do
      conn
      |> send_resp(200, resp_error("wrong params"))
      |> halt
    else
      node_info = %{
        "host" => host,
        "api" => api,
        "type" => type
      }
      NodeManager.add_node(node_info)
      conn
      |> send_resp(200, resp_data("ok"))
      |> halt
    end
  end

  get "/api/node/del" do
    conn = fetch_query_params(conn)
    query_string_map = conn.query_params
    host = query_string_map["host"]
    if host == nil  do
      conn
      |> send_resp(200, resp_error("wrong params"))
      |> halt
    else
      NodeManager.del_node(host)
      conn
      |> send_resp(200, resp_data("ok"))
      |> halt
    end
  end

  get "/api/node/setidc" do
    
  end

  get "/api/node/setidcs" do
    
  end

  get "/api/gid/set" do
    conn = fetch_query_params(conn)
    query_string_map = conn.query_params
    gid = query_string_map["gid"]
    updelay = query_string_map["updelay"]
    idcs = query_string_map["idcs"]
    if gid == nil || updelay == nil || idcs == nil do
      conn
      |> send_resp(200, resp_error("wrong params"))
      |> halt
    else
      gid_info = %{
        "gid" => gid,
        "updelay" => updelay,
        "idcs" => idcs
      }
      DB.set_gid(gid, gid_info)
      conn
      |> send_resp(200, resp_data("ok"))
      |> halt
    end

  end

  get "/api/gid/del" do
    conn = fetch_query_params(conn)
    query_string_map = conn.query_params
    gid = query_string_map["gid"]
    if gid == nil do
      conn
      |> send_resp(200, resp_error("wrong params"))
      |> halt
    else
      DB.del_gid(gid)
      conn
      |> send_resp(200, resp_data("ok"))
      |> halt
    end
  end

  get "/api/gid/show" do
    gids = DB.get_all_gid()
    res = for gid_info <- gids do
      %{
        "gid" => gid_info["gid"],
        "updelay" => gid_info["updelay"],
        "idcs" => gid_info["idcs"]
      }
    end

    conn
    |> send_resp(200, resp_data(res))
    |> halt
  end

  match _ do
    conn
    |> send_resp(404, "Nothing here")
    |> halt
  end
end
