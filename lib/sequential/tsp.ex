defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @min_distance 900
  @population_size 60
  @crossover_rate 0.95
  @mutation_rate 0.001
  @elitism_count 3
  @tournament_size 5


  @doc """
  The entry point for the Sequential TSP algorithm.
  """
  def run do
    population =
      @population_size
      |> Population.new
      |> GeneticAlgorithm.evaluate

    distance = Population.calculate_distance(population)
    IO.puts("Start Distance: #{distance}")

    process_population(population, 1, distance)
  end


  defp process_population(_population, generation, distance)
    when @min_distance >= distance do
      IO.puts("Stopped after #{generation} generations.")
      IO.puts("Best Distance: #{distance}")
  end


  defp process_population(population, generation, _distance) do
    {elite_population, common_population} =
      population
      |> Population.sort
      |> Enum.split(@elitism_count)

    new_general_population =
      common_population
      |> GeneticAlgorithm.crossover(@population_size,
                                    @crossover_rate,
                                    @tournament_size)
      |> GeneticAlgorithm.mutate(@mutation_rate)

    new_population =
      elite_population ++ new_general_population
      |> GeneticAlgorithm.evaluate

    new_distance = Population.calculate_distance(new_population)

    # if new_distance != distance do
    #   IO.puts("G#{generation} Best Distance: #{distance}")
    # end

    process_population(new_population, generation + 1, new_distance)
  end

end
