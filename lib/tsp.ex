defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 100
  @min_distance 70
  @num_cities 40
  @crossover_rate 0.99
  @mutation_rate 0
  @elitism_count 10
  @tournament_size 5

  @doc """
  The entry point for the TSP algorithm.
  """

  def run do
    population =
      Population.new(@num_cities)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(population)
    IO.puts("Start Distance: #{distance}")

    process_population(population, 1, distance)
  end

  defp process_population(_population, generation, distance)
    when @min_distance >= distance do
      IO.puts("Stopped after #{generation} generations.")
      IO.puts("Best Distance: #{distance}")
  end

  defp process_population(population, generation, distance) do
    new_population =
      population
      |> GeneticAlgorithm.crossover(@crossover_rate, @elitism_count, @tournament_size)
      |> GeneticAlgorithm.mutate(@elitism_count, @mutation_rate)
      |> GeneticAlgorithm.evaluate

    new_distance = calculate_distance(new_population)

    if new_distance != distance do
      IO.puts("G#{generation} Best Distance: #{distance}")
    end

    process_population(new_population, generation + 1, new_distance)
  end

  @doc """
  Calculates the shortest distance (using the best candidate solution) for
  the given population.

  Note: function shared with test cases.
  """

  def calculate_distance(%Array{} = population) do
    population
    |> Population.getFittest
    |> Route.new
    |> Route.getDistance
  end
end
