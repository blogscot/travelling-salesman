defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 100
  @min_distance 800
  @num_cities 100
  @crossover_rate 0.9
  @mutation_rate 0.001
  @elitism_count 3
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
    sorted_population = population |> Population.sort

    elite_population = sorted_population |> Enum.take(@elitism_count)

    new_general_population =
      sorted_population
      |> Enum.drop(@elitism_count)
      |> Array.from_list
      |> GeneticAlgorithm.crossover(@crossover_rate, @tournament_size)
      |> GeneticAlgorithm.mutate(@mutation_rate)

    new_population =
      elite_population ++ new_general_population
      |> Array.from_list
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
