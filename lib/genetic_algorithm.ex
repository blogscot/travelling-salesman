defmodule GeneticAlgorithm do

  @moduledoc """
  Contains the genetic operators for the Travelling Salesman problem
  """


  @doc """
  Creates the initial population of candidate solutions, each
  chromosome having the specified length.

    population_size     number of candidate solutions
    chromosome_length   length of chromosome
  """

  def initialise(population_size, chromosome_length) do
    Population.new(population_size, chromosome_length)
  end


  @doc """
  Evaluates true when generation count limit has been reached.
  """

  def terminateSearch?(count, limit), do: count > limit

  @doc """
  Calculates the fitness of a candidate solution.
  """

  def calcFitness(chromosome) when is_map(chromosome) do
    distance =
      chromosome
      |> Route.new
      |> Route.getDistance

    # short distances are fitter than long distances
    1 / distance
  end

  @doc """
  Calculates the population average fitness.
  """

  def evaluate(population) when is_map(population) do
    population
    |> Enum.map(fn {_, chromosome} ->
      GeneticAlgorithm.calcFitness(chromosome)
    end) |> Enum.sum
         |> Kernel./(map_size(population))
  end

end