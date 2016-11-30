defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 100
  @min_distance 700
  @num_cities 40
  @mutation_rate 0.001
  @crossover_rate 0.95
  @elitism_count 3
  @tournament_size 5

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
    IO.puts("G#{generation} Best Distance: #{distance}")

    new_population =
      population
      |> GeneticAlgorithm.crossover(@crossover_rate, @elitism_count, @tournament_size)
      |> GeneticAlgorithm.mutate(@elitism_count, @mutation_rate)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(new_population)
    process_population(new_population, generation + 1, distance)
  end

  def calculate_distance(%Array{} = population) do
    population
    |> Population.getFittest
    |> Route.new
    |> Route.getDistance
  end
end
