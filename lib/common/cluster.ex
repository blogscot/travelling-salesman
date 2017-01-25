defmodule Cluster do

  @moduledoc """
  Functions for managing a cluster of distributed machines
  """

  @number_workers :erlang.system_info(:logical_processors)


  @doc """
  Creates a pool of worker processes on local machine and remote machines
  using the passed function.

  TODO: expand for multiple nodes
  """
  def create_worker_pool(fun) do

    # Before spawning remote worker processes we need to be connected!
    connected_nodes = connect()

    local_processes = Enum.map(1..@number_workers,
      fn _ -> spawn(fun) end)

    node2 = List.first(connected_nodes)

    remote_processes = Enum.map(1..@number_workers,
      fn _ -> Node.spawn(node2, fun) end)

    local_processes ++ remote_processes
  end

  # Connects to remote nodes defined in the config file.
  # Raises a runtime error if any node fails to connect.

  defp connect do
    # Read remote node info from config
    nodes = Application.get_env(:tsp, :nodes)

    status = for node <- nodes, do: Node.connect(node)

    # Are all nodes connected?
    case Enum.all?(status, &(&1)) do
      true ->
        IO.puts "Successfully connected to #{inspect nodes}"
        nodes
      false ->
        raise "Unable to connect to remote nodes, status: #{inspect status}"
    end
  end

end
