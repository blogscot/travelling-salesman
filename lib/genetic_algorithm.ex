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

  def updateFitness(%Individual{chromosome: chromosome}=individual) do
    distance =
      chromosome
      |> Route.new
      |> Route.getDistance

    # short distances are fitter than long distances
    %Individual{individual | fitness:  1 / distance}
  end

  @doc """
  Updates the fitness for each pop
  """

def updateFitness(population) when is_map(population) do
  population
  |> Stream.map(fn {key, individual} ->
    {key, updateFitness(individual)}
  end) |> Enum.into(%{})
end

  @doc """
  Calculates the population average fitness.
  """

  def evaluate(population) when is_map(population) do
    population
    |> updateFitness
    |> Stream.map(fn {_, individual} ->
      individual.fitness
    end) |> Enum.sum
         |> Kernel./(map_size(population))
  end

  @doc """
  Mutates members of the population according to the mutation rate.

  Note: the first n fittest members are allowed into the new population
  without mutation, where n = elitismCount.
  """

  def mutate(population, elitismCount, mutationRate) when is_map(population) do
    sorted_population = population |> Population.sort

    elite = sorted_population |> Enum.take(elitismCount) |> Enum.into(%{})

    non_elite =
      sorted_population
      |> Enum.drop(elitismCount)
      |> Enum.map(fn {key, ind} ->
        {key, ind |> Individual.mutate(mutationRate)}
      end) |> Enum.into(%{})

    Map.merge(elite, non_elite)
  end

end
