defmodule Tsp do

  @moduledoc """
  The main module for the Travelling Salesman Problem
  """

  @max_generation 10000

  def run do
    population = GeneticAlgorithm.updateFitness(Population.new(10))
    Population.getFittest(population)
    |> Route.new
    |> Route.getDistance
  end
end
