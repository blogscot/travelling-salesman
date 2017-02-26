defmodule Population do

  @moduledoc """
  A population is a collection of chromosomes (aka individuals).
  """


  @doc """
  Creates a population of candidate solutions (aka individuals) with
  the chromosomes of the population size.
  """
  def new(population_size) when population_size > 0 do
    for _ <- 0..population_size - 1, do:
      Individual.new(population_size)
  end


  @doc """
  Creates a population of candidate solutions (aka individuals) with
  the chromosomes of the specified length.
  """
  def new(population_size, chromosome_length) do
    for _ <- 0..population_size - 1, do:
      Individual.new(chromosome_length)
  end


  @doc """
  Updates the individual in a population at the given position.

  This is currently only used in test and may be deleted.
  """
  def setIndividual(%Array{} = population, %Individual {} = individual, offset) do
    Array.set(population, offset, individual)
  end


  @doc """
  Returns a population member at the given offset.

  This is currently only used in test and may be deleted.
  """
  def getIndividual(%Array{} = population, offset) do
    population[offset]
  end


  @doc """
  Orders the population members according to their fitness.
  """
  def sort(population) do
    population
    |> Enum.sort_by(&(&1.fitness), &(&1 > &2))
  end


  @doc """
  Finds the fittest individual in the population.
  If an offset is given, it finds the nth fittest individual.
  """
  def getFittest(population, offset \\ 0) when offset >= 0 do
    population
    |> sort
    |> Enum.at(offset)
  end


  @doc """
  Shuffles the population of candidate solutions.
  Note: the chromosome contents remain untouched.
  """
  def shuffle(population) do
    population
    |> Enum.shuffle
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
