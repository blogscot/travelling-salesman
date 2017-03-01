defmodule Tsp.MasterSlave do
  require Logger

  @moduledoc """
  The main module for the Master-slave model algorithm
  """

  @min_distance 900
  @population_size 60
  @crossover_rate 0.95
  @mutation_rate 0.005
  @elitism_count 3
  @tournament_size 5

  def get_log_params do
    %{min_distance: @min_distance, population_size: @population_size,
     crossover_rate: @crossover_rate, mutation_rate: @mutation_rate,
     elitism_count: @elitism_count, tournament_size: @tournament_size}
  end


  @doc """
  The entry point for the TSP algorithm.
  """
  def run do
    pool = Cluster.create_worker_pool(&crossover_population/0)

    # Evaluate the initial population
    population =
      Population.new(@population_size)
      |> GeneticAlgorithm.evaluate

    distance = Population.calculate_distance(population)

    process_population(population, pool, 1, distance)
  end

  # Perform crossover and mutation of a sub-population
  defp process_population(_population, pool, generation, distance)
    when @min_distance >= distance do

    IO.puts("Stopped after #{generation} generations.")
    IO.puts("Best Distance: #{distance}")

    Logger.info("Test completed after #{generation} generations")

    # Clean up resources
    pool |> Enum.map(&stop_worker/1)
  end

  defp process_population(population, pool, generation, _distance) do
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    new_general_population =
      common_population
      |> Utilities.divide(length(pool))
      |> Enum.zip(Stream.cycle(pool))
      |> Enum.map(&start_worker/1)
      |> Enum.flat_map(&await_result/1)

    new_population =
      elite_population ++ new_general_population
      |> GeneticAlgorithm.evaluate

    new_distance = Population.calculate_distance(new_population)

    # if new_distance != distance do
    #   IO.puts("G#{generation} Best Distance: #{distance}")
    # end

    process_population(new_population, pool, generation + 1, new_distance)
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
        crossover_population()
      {:done, _from} ->
        :ok
    end
  end

  # Sends sub-population to worker process.
  defp start_worker({population, worker_pid}) do
    send(worker_pid, {:population, population, self()})
  end

  defp stop_worker(worker_pid) do
    send(worker_pid, {:done, self()})
  end

  # Waits for the response from the worker process.
  defp await_result(_) do
    receive do
      {:crossedover, population} ->
        population
    end
  end

end
