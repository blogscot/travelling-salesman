defmodule Tsp.Cellular do
  require Logger

  @moduledoc """
  A Cellular solution to the Travelling Salesman problem.

  This cellular solution is largely based on Island Model algorithm, with
  the difference being the cellular algorithm communicates its immediately adjacent
  neighbouring processes in a grid pattern (i.e. positions north, east, south,
  and west).
  """

  @min_distance 900
  @population_size 60
  @crossover_rate 0.95
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5
  @migration_gap 20

  def get_log_params do
    "Distance: #{@min_distance} Population: #{@population_size}, Crossover #{@crossover_rate}, " <>
      "Mutation: #{@mutation_rate}, Elitism: #{@elitism_count}, Tournament: #{@tournament_size}, " <>
      "Migration: #{@migration_gap}"
  end

  @doc """
  The master process for the Cellular model algorithm.

  Spawns and initialisses the worker processes then waits until a worker
  reports that it has found a suitable candidate solution.
  """
  def run(row, col) do
    pool = Cluster.create_worker_pool(fn -> start_worker({row, col}) end)

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
    flush()  # Clear out any duplicate solutions
  end

  # Clears all mailbox messages for the calling process
  def flush do
    receive do
      _msg ->
        flush()
    after
      10 -> :ok
    end
  end

  # Waits for the worker pool from the master process, and from this
  # calculates this process' neighbours list. Also returns the master
  # pid.
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
    process_population(population, {master, neighbours}, 1, distance)
  end

  # Replies to master process when a suitable solution has been found
  defp process_population(_population, {master, _neighbours}, generation, distance)
  when (@min_distance >= distance) do
    send master, {:distance, distance, generation}
  end


  # Perform crossover and mutation of a population
  defp process_population(population, {_, neighbours} = pool, generation, _distance) do

    # select elite and non-elite population based on fitness value
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    general_population =
      common_population
      |> GeneticAlgorithm.crossover(@population_size, @crossover_rate, @tournament_size)
      |> GeneticAlgorithm.mutate(@mutation_rate)

    migrated_population =
    if (rem generation, @migration_gap) == 0 do
      send_elites(neighbours, elite_population)

      neighbours
      |> length
      |> await_elites
      |> integrate(general_population)
    else
      general_population
    end

    # update population fitness
    new_population =
      elite_population ++ migrated_population
      |> GeneticAlgorithm.evaluate

    new_distance = Population.calculate_distance(new_population)

    process_population(new_population, pool, generation + 1, new_distance)
  end


  # Sends elite members to neighbouring worker processes
  def send_elites(neighbours, elites) do
    for neighbour <- neighbours, do:
      send neighbour, {self(), elites: elites}
  end

  # Merges the new elite population into the general population.
  # Some members are randomly dropped to maintain constant population size.
  def integrate(elites, population) when is_list(population) do
    elites ++ population
    |> Enum.shuffle
    |> Enum.take(length(population))
  end

  # Waits for response messages from neighbour processes
  # which are added to the population.
  def await_elites(count, population \\ [])
  def await_elites(0, population), do: population
  def await_elites(count, population) when count > 0 do
    receive do
      {_from, elites: elites} when is_list(elites) ->
        await_elites(count - 1, elites ++ population)
    end
  end

  @doc """
  Returns the values neighbouring the given value in array
  or nil if the value is not found.
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
          |> MultiArray.sanatise(workers)
          |> MultiArray.get_value(workers)
        end)
        |> Enum.uniq
    end
  end

end
