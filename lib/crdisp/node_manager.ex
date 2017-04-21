defmodule NodeManager do
  use GenServer
  import Supervisor.Spec

  def start_link(node_sup) do
    GenServer.start_link(__MODULE__, node_sup, [name: __MODULE__])
  end

  def init(node_sup) do
    :ets.new(:node_table, [:set, :public, :named_table])
    
    {:ok, {node_sup}}
  end

  def add_node(node_info) do
    GenServer.call(__MODULE__, {:add_node, node_info})
  end

  def handle_call({:add_node, node_info}, _from, state = {node_sup}) do
    IO.puts("handle add node: #{node_info["host"]}")
    node_id = node_info["host"]
    case :ets.lookup(:node_table, node_id) do
      [] ->
        IO.puts("add node: #{node_info["host"]}")
        Supervisor.start_child(node_sup, [node_info])
        {:reply, :ok, state}
      [_] ->
        IO.puts("no add: #{node_info["host"]}")
        {:reply, :ok, state}
    end
  end

  def del_node(host) do
    GenServer.call(__MODULE__, {:del_node, host})
  end

  def handle_call({:del_node, host}, _from, state = {node_sup}) do
    node_id = host
    case :ets.lookup(:node_table, node_id) do
      [] ->
        {:reply, :ok, state}
      [node_worker] ->
        Supervisor.terminate_child(node_sup, node_worker)
        {:reply, :ok, state}
    end
  end

  def nodes() do
    GenServer.call(__MODULE__, {:nodes})
  end
  def handle_call({:nodes}, _from, state) do
    nodes = :ets.match(:node_table, :"$1")
    nodes_out = for [x] <- nodes, do: x
    {:reply, nodes, state}
  end

  def set_gid(gid, idcs, updelay) do
    gid_conf = %{}
    |> Map.put("gid", gid)
    |> Map.put("idcs", idcs)
    |> Map.put("updelay", updelay)
    |> Map.put("uptime", :os.timestamp())
    DB.set_gid(gid, gid_conf)

  end
