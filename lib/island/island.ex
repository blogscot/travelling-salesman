defmodule Tsp.Island do
  require Logger

  @min_distance 90
  @population_size 10
  @crossover_rate 0.95
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5
  @migration_rate 200


  @doc """
  The master process for the Island model.

  Spawns and initialisses the worker processes then waits until a worker
  reports that it has found a suitable candidate solution.
  """
  def run do
    pool = Cluster.create_worker_pool(&start_worker/0)

    # initialise each worker
    for worker <- pool do
      send worker, {:workers, pool, self()}
    end

    # Wait for a worker to send the final solution
    receive do
      {:distance, distance, generation} ->
        IO.puts("G#{generation} Best Distance: #{distance}")
    end
  end


  # Waits for the worker pool from the master process, and from this
  # calculates this process' neighbours list. Also returns the master
  # pid.
  defp find_neighbours() do
    receive do
      {:workers, worker_pool, from} ->
        neighbours = calculate_neighbours(worker_pool)
        {from, neighbours}
    end
  end


  # Starts the worker process
  defp start_worker() do
    {master, neighbours} = find_neighbours()

    population =
      Population.new(@population_size)
      |> GeneticAlgorithm.evaluate()

    distance = calculate_distance(population)
    process_population(population, {master, neighbours}, 1, distance)
  end


  # Replies to master process when a suitable solution has been found
  defp process_population(_population, {master, _neighbours}, generation, distance)
  when (@min_distance >= distance) do

    send master, {:distance, distance, generation}
    Logger.info("Test completed after #{generation} generations")
  end


  # Perform crossover and mutation of a population
  defp process_population(population, {_, neighbours}=pool, generation, _) do
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    general_population =
      common_population
      |> GeneticAlgorithm.crossover(@population_size, @crossover_rate, @tournament_size)
      |> GeneticAlgorithm.mutate(@mutation_rate)

    IO.puts("#{inspect general_population}")

    new_general_population =
    if (rem generation, @migration_rate) == 0 do
      send_elites(neighbours, elite_population)
      updated_population =
        await_elites(length(neighbours))
        |> integrate(general_population)
      IO.puts("#{inspect updated_population}")
    end

    IO.write("#{length(new_general_population)}")
    new_population =
      elite_population ++ new_general_population
      |> GeneticAlgorithm.evaluate

    new_distance = calculate_distance(new_population)
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


  # Calculates the shortest distance (using the best candidate solution) for
  # the given population.
  def calculate_distance(population) when is_list(population) do
    population
    |> Population.getFittest
    |> Route.new
    |> Route.getDistance
  end

  @doc """
  Returns the neighbouring process pids.

  Given an ordered list of pids the neighbours are the ones
  immediately before and after the current pid.
  """
  def calculate_neighbours(workers) when is_list(workers) do
    # find current pid index in list of worker pids
    index = Enum.find_index(workers, &(&1==self()))

    len = length(workers)
    previous = rem (index - 1) + len, len
    next = rem (index + 1), len
    case len do
      1 -> []
      2 ->
        [workers |> Enum.at(next)]
      _ ->
        [workers |> Enum.at(previous), workers |> Enum.at(next)]
    end
  end

end
