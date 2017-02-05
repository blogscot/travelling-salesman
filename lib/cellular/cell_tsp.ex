defmodule Cellular.Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem.

  The cellular algorithm run across a distributed cluster which
  must be set up prior to execution. The distributed nodes may
  be located on the same machine, or alternatively on machines
  accessible via their IP addresses.

  To connect to local nodes set up the cluster using short names:

  iex --sname node1 --cookie fudge
  iex --sname node2 --cookie fudge

  To connect to remote nodes use the following commands:

  iex --name node1@127.0.0.1 --cookie fudge -S mix
  iex --name node2@127.0.0.1 --cookie fudge -S mix
  """

  @min_distance 900
  @population_size 60
  @crossover_rate 0.9
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5

  @doc """
  The entry point for the TSP algorithm.
  """
  def run do
    pool = Cluster.create_worker_pool(&mutate_individual/0)

    population =
      Population.new(@population_size)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(population)
    IO.puts("Start Distance: #{distance}")

    process_population(population, pool, 1, distance)
  end

  # Mutates the received individual, returning the result back to sender.

  defp mutate_individual do
    receive do
      {:individual, individual, from} ->
        send(from, {:mutated, individual |> Individual.mutate(@mutation_rate)})
        mutate_individual()
    end
  end

  # Sends a individual to be mutated by a pool worker.

  defp start_worker({individual, worker_pid}) do
    send(worker_pid, {:individual, individual, self()})
  end

  # Waits for a mutated response message.

  defp await_result(_) do
    receive do
      {:mutated, individual} -> individual
    end
  end

  defp process_population(_population, _pool, generation, distance)
    when @min_distance >= distance do
      IO.puts("Stopped after #{generation} generations.")
      IO.puts("Best Distance: #{distance}")
  end

  defp process_population(population, pool, generation, distance) do
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    crossover_population =
      common_population
      |> GeneticAlgorithm.crossover(@population_size,
                                    @crossover_rate,
                                    @tournament_size)

    new_general_population =
      crossover_population
      |> Enum.zip(Stream.cycle(pool))
      |> Enum.map(&start_worker/1)
      |> Enum.map(&await_result/1)

    new_population =
      elite_population ++ new_general_population
      |> GeneticAlgorithm.evaluate

    new_distance = calculate_distance(new_population)

    if new_distance != distance do
      IO.puts("G#{generation} Best Distance: #{distance}")
    end

    process_population(new_population, pool, generation + 1, new_distance)
  end


  @doc """
  Calculates the shortest distance (using the best candidate solution) for
  the given population.

  Note: function shared with test cases.
  """

  def calculate_distance(population) do
    population
    |> Population.getFittest
    |> Route.new
    |> Route.getDistance
  end
end
