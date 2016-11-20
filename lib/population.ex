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
    |> Enum.into(%{}, fn x -> {x, Individual.new(chromosome_length)} end)
  end

  @doc """
  Updates the individual in a population at the given position.
  """

  def setIndividual(%{}=individual, %{}=population, offset) do
    Map.update(population, offset, nil, &(&1=individual))
  end

  @doc """
  Returns a population member at the given offset.
  """

  def getIndividual(%{}=population, offset) do
    population[offset]
  end

  @doc """
  Orders the population members according to their fitness.
  """

  def sort(%{}=population) do
    population
    |> Enum.sort_by(fn {_key, individual} -> individual.fitness end,
                  &(&1>&2))
  end

  @doc """
  Finds the fittest individual in the population.
  If an offset is given, it finds the nth fittest individual.
  """

  def getFittest(%{}=population, offset \\ 0) when offset >= 0 do
    population
    |> sort
    |> Enum.at(offset)
    |> (fn {_key, individual} -> individual end).()
  end

  @doc """
  Shuffles the population of candidate solutions.
  Note: the chromosome contents remain untouched.
  """

  def shuffle(%{}=population) do
    population
    |> Map.keys
    |> Enum.shuffle
    |> Enum.zip(population |> Map.values)
    |> Enum.into(%{})
  end

end
