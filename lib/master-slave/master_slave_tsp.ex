defmodule MasterSlave.Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 100
  @min_distance 80
  @population_size 80
  @crossover_rate 0.9
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5
  @number_workers 4

  @doc """
  The entry point for the TSP algorithm.
  """

  def run do
    population =
      Population.new(@population_size)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(population)
    IO.puts("Start Distance: #{distance}")

    # Create worker pool
    pool = Enum.map(1..@number_workers, fn _ -> spawn(&crossover_population/0) end)

    process_population(population, pool, 1, distance)
  end

  def crossover_population do
    receive do
      {:population, population, from} ->
        send(from, {:crossedover,
          population
          |> GeneticAlgorithm.crossover(@population_size,
                                        @crossover_rate,
                                        @tournament_size)
          |> GeneticAlgorithm.mutate(@mutation_rate)
          })
        crossover_population
    end
  end

  defp start_worker({population, worker_pid}) do
    send(worker_pid, {:population, population, self})
  end

  defp await_result(_) do
    receive do
      {:crossedover, population} -> population
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

    new_general_population =
      common_population
      |> Utilities.divide(@number_workers)
      |> Enum.zip(Stream.cycle(pool))
      |> Enum.map(&start_worker/1)
      |> Enum.flat_map(&await_result/1)

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
