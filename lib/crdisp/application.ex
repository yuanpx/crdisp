defmodule Crdisp.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    server_type = Application.get_env(:server, :run_type)

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Crdisp.Worker.start_link(arg1, arg2, arg3)
      # worker(Crdisp.Worker, [arg1, arg2, arg3]),
      worker(Mongo,[[name: :DBPool, hostname: "127.0.0.1", port: 27017, database: "crossroads"]]),
      worker(Api, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crdisp.Supervisor]
    {:ok, main_sup} = Supervisor.start_link(children, opts)
    #if server_type == "back" do
    {:ok, node_sup} = Supervisor.start_child(main_sup,  supervisor(NodeSup, [], [restart: :temporary]))
    {:ok, _} = Supervisor.start_child(main_sup, worker(NodeManager, [node_sup], [restart: :temporary]))
    #end

    {:ok, main_sup}
  end
end
