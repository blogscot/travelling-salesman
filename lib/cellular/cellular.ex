defmodule Tsp.Cellular do
  require Logger

  @moduledoc """
  A Cellular solution to the Travelling Salesman problem.

  This cellular solution is largely based on the Island Model algorithm, with
  the difference being the cellular algorithm communicates with its cellular
  neighbour, based on a grid pattern (i.e. positions north, east, south, and
  west).
  """
  @min_distance 900
  @population_size 60
  @crossover_rate 0.95
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5
  @migration_gap 10

  def get_log_params do
    "Distance: #{@min_distance} Population: #{@population_size}, Crossover #{@crossover_rate}, " <>
      "Mutation: #{@mutation_rate}, Elitism: #{@elitism_count}, Tournament: #{@tournament_size}, " <>
      "Migration: #{@migration_gap}"
  end

  @doc """
  The master process for the Cellular model algorithm.

  Spawns and initialisses the worker process pool then waits until a worker
  reports that it has found a suitable candidate solution.
  """
  def run(num_workers, {row, col}) do
    pool = Cluster.create_worker_pool(num_workers, fn -> start_worker({row, col}) end)

    # initialise each worker
    for worker <- pool do
      send worker, {:workers, pool, self()}
    end

    # Wait for the first worker to send the final solution
    receive do
      {:distance, distance, generation} ->
        Logger.info("Test completed after #{generation} generations")
        IO.puts("Complete at generation: #{generation}, distance: #{distance}")
    end

    # Clean up resources
    _ = pool |> Enum.map(fn pid -> Process.exit(pid, :kill) end)
    Utilities.flush()  # Clear out any duplicate solutions
  end


  # Waits for the worker pool message from the master process. From this
  # calculates this process' neighbours list.
  # Returns this neighbour list and the master pid.
  defp find_neighbours({row, col}) when row > 0 and row > 0 do
    receive do
      {:workers, worker_pool, from} ->
        workers = worker_pool |> MultiArray.from_list(row, col)
        neighbours = calculate_neighbours(workers)
        {from, neighbours}
    end
  end


  # Starts the worker process
  defp start_worker(grid_dimensions) do
    {master, neighbours} = find_neighbours(grid_dimensions)

    population =
      @population_size
      |> Population.new
      |> GeneticAlgorithm.evaluate()

    distance = Population.calculate_distance(population)
    Tsp.Island.process_population(population, {master, neighbours}, 1, distance)
  end


  @doc """
  Returns the values neighbouring the given value in array
  (or nil if the value is not found).
  Neighbours are in north, east, south, west grid positions.
  """
  def calculate_neighbours(workers) when is_list(workers) do
    offsets = [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    case MultiArray.find_index(workers, self()) do
      nil -> nil
      {row, col} ->
        offsets
        |> Enum.map(fn {r, c} ->
          {r + row, c + col}
          |> MultiArray.sanitise(workers)
          |> MultiArray.get_value(workers)
        end)
        |> Enum.uniq
    end
  end

end
