defmodule Tsp.Island.Async do
  require Logger
  alias Tsp.Island

  @moduledoc """
  The main module for the Island model algorithm

  Each island process works on its own population to find the solution specified by
  the minimum distance value. Occasionally (see Migration Gap) an island's best candidates
  are migrated between neighbouring islands.
  When an island finds a solution with the required fitness value it informs the master
  process, which in turn reports the solution and cleans up the remaining resources.
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
  The master process for the Island model.

  Spawns and initialisses the worker processes then waits until a worker
  reports that it has found a suitable candidate solution.
  """
  def run(num_workers) do
    pool = Cluster.create_worker_pool(num_workers, &start_worker/0)

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


  # Starts the worker process
  defp start_worker() do
    {master, neighbours} = Island.find_neighbours()

    population =
      @population_size
      |> Population.new
      |> GeneticAlgorithm.evaluate()

    distance = Population.calculate_distance(population)
    process_population(population, {master, neighbours}, 1, distance)
  end

  # Replies to master process when a suitable solution has been found
  def process_population(_population, {master, _neighbours}, generation, distance)
  when (@min_distance >= distance) do
    send master, {:distance, distance, generation}
  end


  # Perform crossover and mutation of a population
  def process_population(population, {_, neighbours} = pool, generation, _distance) do

    # select elite and non-elite population based on fitness value
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    general_population =
      common_population
      |> GeneticAlgorithm.crossover(@population_size, @crossover_rate, @tournament_size)
      |> GeneticAlgorithm.mutate(@mutation_rate)

    if (rem generation, @migration_gap) == 0 do
      Island.send_elites(neighbours, elite_population)
    end

    migrated_population =
      neighbours
      |> length
      |> await_elites
      |> Island.integrate(general_population)

    # update population fitness
    new_population =
      elite_population ++ migrated_population
      |> GeneticAlgorithm.evaluate

    new_distance = Population.calculate_distance(new_population)

    process_population(new_population, pool, generation + 1, new_distance)
  end

  # Process any received migration messages (up to a maximum
  # number given by count) from the neighbouring processes.
  # This is a non-blocking function.
  def await_elites(count, population \\ [])
  def await_elites(0, population), do: population
  def await_elites(count, population) when count > 0 do
    receive do
      {_from, elites: elites} when is_list(elites) ->
        await_elites(count - 1, elites ++ population)
    after
      0 ->
        # if mailbox empty, return current population
        await_elites(0, population)
    end
  end

end
