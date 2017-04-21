defmodule DB do

  def get_baseconf() do
    res = Enum.to_list(Mongo.find(:DBPool, "common", %{"base" => "base"}))
    case res do
      [] -> nil
      [one] -> one
    end
  end

  def set_idcs(idcs) do
    Mongo.update_one(:DBPool, "common", %{"base" => "base"}, %{"idcs" => idcs})

  end

  def set_rapi(rapi) do
    Mongo.update_one(:DBPool, "common", %{"base" => "base"}, %{"rapi" => rapi})
  end

  def get_all_gid() do
    Enum.to_list(Mongo.find(:DBPool, "gidconf", %{}))
  end

  def set_gid(gid, gidconf) do
    Mongo.update_one(:DBPool, "gidconf", %{"gid" => gid}, gidconf)
  end

  def del_gid(gid) do
    Mongo.delete_one(:DBPool, "gidconf", %{"gid" => gid})
  end

  def get_all_node() do
    Enum.to_list(Mongo.find(:DBPool, "node", %{}))
  end

  def set_node(host, node) do
    Mongo.update_one(:DBPool, "node", %{"host" => host}, node)
  end

  def del_node(host) do
    Mongo.delete_one(:DBPool, "node", %{"host" => host})
  end

  def get_old_gids(synctime) do
    Enum.to_list(Mongo.find(:DBPool, "gidconf", %{"uptime" => %{"$gt" => synctime}}, sort: %{"uptime" => 1}))
  end

end

