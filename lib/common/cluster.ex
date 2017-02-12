defmodule Cluster do

  @moduledoc """
  Functions for managing a cluster of distributed machines
  """

  # @number_workers :erlang.system_info(:logical_processors)
  @number_workers 2

  def number_workers, do: @number_workers
  def get_nodes, do: Application.get_env(:tsp, :nodes)
  def number_nodes, do: length(get_nodes())

  @doc """
  Creates a pool of worker processes on local machine and remote machines
  using the passed function.
  """
  def create_worker_pool(fun) do

    # Before spawning worker processes we need to be connected!
    connected_nodes = connect_nodes()

    # Spawn processes on all connected nodes
    for node <- connected_nodes,
      _ <- 1..@number_workers, do: Node.spawn(node, fun)

  end


  # Connects to remote nodes defined in the config file.
  # Raises a runtime error if any node fails to connect.
  defp connect_nodes do
    # Reads the node info from config.exs
    nodes = get_nodes()
    # IO.inspect nodes

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
