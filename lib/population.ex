defmodule Population do
  @moduledoc """
  A population is a collection of chromosomes (aka individuals).
  """

  @doc """
  Creates a population of candidate solutions (aka individuals) with
  the chromosomes of the population size.
  """

  def new(population_size) when population_size > 0 do
    0..population_size-1
    |> Enum.reduce(%{},
        fn x, acc -> Map.update(acc, x, Individual.new(population_size), &(&1)) end)
  end

  @doc """
  Creates a population of candidate solutions (aka individuals) with
  the chromosomes of the specified length.
  """

  def new(population_size, chromosome_length)
    when population_size > 0 and chromosome_length > 0 do
    0..population_size-1
    |> Enum.reduce(%{},
        fn x, acc -> Map.update(acc, x, Individual.new(chromosome_length), &(&1)) end)
  end

  @doc """
  Returns the number of individuals in the population
  """

  def setIndividual(individual, population, offset)
      when is_map(population) and is_map(individual) do
    Map.update(population, offset, nil, &(&1=individual))
  end

  def getIndividual(population, offset) when is_map(population) do
    population[offset]
  end

  @doc """
  Shuffles the population of candidate solutions.
  Note: the chromosome contents remain untouched.
  """

  def shuffle(population) do
    population
    |> Map.keys
    |> Enum.shuffle
    |> Enum.zip(population |> Map.values)
    |> Enum.into(%{})
  end

  @doc """
  Returns the size of the population
  """

  def size(population) when is_map(population) do
    population |> Map.to_list |> length
  end

end