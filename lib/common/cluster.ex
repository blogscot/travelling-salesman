defmodule Cluster do

  @moduledoc """
  Functions for managing a cluster of distributed machines
  """

  def get_nodes, do: Application.get_env(:tsp, :nodes)
  def number_nodes, do: length(get_nodes())

  @doc """
  Creates a pool of worker processes on the connected nodes.
  Each node executes the given function.
  """
  def create_worker_pool(number_workers, fun) do

    # Before spawning worker processes we need to be connected!
    connected_nodes = connect_nodes()

    # Spawn processes on all connected nodes
    for node <- connected_nodes,
      _ <- 1..number_workers, do: Node.spawn(node, fun)
  end


  # Connects to nodes as defined in the application's config file.
  # These may be local or remote nodes depending on the given IP address.
  # Raises a runtime error if any node fails to connect.
  defp connect_nodes do
    # Reads the node info from config.exs
    nodes = get_nodes()
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
