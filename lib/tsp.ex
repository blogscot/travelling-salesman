defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 100
  @numCities 33
  @mutationRate 0.001
  @crossoverRate 0.9
  @elitismCount 3
  @tournamentSize 5

  def run do
    population =
      Population.new(@numCities)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(population)
    IO.puts("Start Distance: #{distance}")

    process_population(population, 1, distance)
  end

  defp process_population(_population, generation, distance)
    when generation >= @max_generation do
      IO.puts("Stopped after #{generation} generations.")
      IO.puts("Best Distance: #{distance}")
    end
  defp process_population(population, generation, distance) do
    IO.puts("G#{generation} Best Distance: #{distance}")

    new_population =
      population
      |> GeneticAlgorithm.crossover(@crossoverRate, @elitismCount, @tournamentSize)
      |> GeneticAlgorithm.mutate(@elitismCount, @mutationRate)
      |> GeneticAlgorithm.evaluate

    distance = calculate_distance(new_population)
    process_population(new_population, generation+1, distance)
  end

  def calculate_distance(population) do
    population
    |> Population.getFittest
    |> Route.new
    |> Route.getDistance
  end
end
