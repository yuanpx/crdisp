defmodule NodeWorker do
  use GenServer

  def start_link(node_info) do
    GenServer.start_link(__MODULE__, node_info)
  end

  def init(node_info) do
    node_id = node_info["host"]
    IO.puts("add #{node_id}")
    true = :ets.insert(:node_table, {node_id, self()})
    :timer.send_after(20000, :tick)
    {:ok, node_info}
  end

  def handle_info(:tick, node_info) do
    synctime = node_info["synctime"]
    gids = DB.get_old_gids(node_info["synctime"])
    newtime = synctime
    new_times = for gid_info <- gids do
      key = gid_info["gid"]
      value = "#{gid_info["idcs"]}|#{gid_info["uptime"]},#{gid_info["updelay"]}"
      set(node_info["api"], key, value)
      node_info["uptime"]
    end

    newtime = case new_times do
      [] -> newtime
      _ -> :lists.last(new_times)
    end

    node_info = if newtime > synctime do
      DB.set_node(node_info["host"], node_info)
      %{node_info | "synctime" => newtime}
    else
      node_info
    end
    IO.puts("#{node_info["host"]} tick!!!")
    :timer.send_after(20000, :tick)
    {:noreply, node_info}
  end

  def make_node_id(ip, port) do
    "#{ip}:#{port}"
  end

  def call(host, ac, params) do
    url = "http://#{host}/#{ac}"
    Httpotion.get(url, query: params)
  end

  def set(host, key, value) do
    params= %{} |> Map.put("k", key) |> Map.put("v", value)
    call(host, "set", params)
  end

  def get(host, key) do
    params = %{} |> Map.put("k", key)
    call(host, "get", params)
  end

  def del(host, key) do
    params = %{} |> Map.put("k", key)
    call(host, "del", params)
  end

  def upgrade(host, version, package_name, script) do
    params = %{} |> Map.put("version", version) |> Map.put("package_name", package_name) |> Map.put("script", script)
    call(host, "upgrade", params)
  end

  def set_rapi(host, apis) do
    params = %{} |> Map.put("apis", apis)
    call(host, "set_rapi", params)
  end

  def enable_idc(host, idc) do
    params = %{} |> Map.put("idc", idc)
    call(host, "enable_idc", params)
  end

  def disable_idc(host, idc) do
    params = %{} |> Map.put("idc", idc)
    call(host, "disable_idc", params)
  end

  def clear_group_status(host, gid) do
    params = %{} |> Map.put("gid", gid)
    call(host, "st_group_clear", params)
  end

  def get_group_status(host, gid) do
    params = %{} |> Map.put("gid", gid)
    call(host, "st_group", params)
  end

  def get_node_status(host) do
    call(host, "st", %{})
  end

  def get_idc_status(host, idcs) do
    idcs_string = Enum.join(idcs, ",")
    params = %{} |> Map.put("idcs", idcs_string)
    call(host, "st_idcs", params)
  end

  def get_status(host, idcs) do
    idcs_string = Enum.join(idcs, ",")
    params = %{} |> Map.put("status", idcs_string)
    call(host, "status", params)
  end
end
