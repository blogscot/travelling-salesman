defmodule AgentBench do
  use Benchfella

  # Is it quicker to read from the config file, an Agent
  # or the ETS store?

  # ## AgentBench
  # benchmark name         iterations   average time
  # read from ets table      10000000   0.37 µs/op
  # read from config file    10000000   0.62 µs/op
  # read from agent            500000   6.06 µs/op

  def setup_node_info do
    node_info = Application.get_env(:tsp, :nodes)
    {:ok, agent} = Agent.start fn -> node_info end
    agent
  end

  def store_node_info do
    node_info = Application.get_env(:tsp, :nodes)
    :ets.new(:node_info, [:named_table])
    :ets.insert(:node_info, {"node_key", node_info})
  end

  bench "read from config file" do
    Application.get_env(:tsp, :nodes)
  end

  bench "read from agent", [agent_pid: setup_node_info()] do
    Agent.get(agent_pid, &(&1))
  end

  bench "read from ets table", [_init: store_node_info()] do
    :ets.lookup(:node_info, "node_key")
  end

end
