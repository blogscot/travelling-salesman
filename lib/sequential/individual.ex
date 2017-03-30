defmodule Individual do
  defstruct chromosome: %Array{}, fitness: nil

  @moduledoc """
  An Individual represents a possible candidate solution represented
  by a chromosome which is an ordered route through a list of cities.
  The suitability of the solution is given by its fitness value.
  """


  @doc """
  Creates a new chromosome of the specified length.
  City genes are in the range 0,1,2 .. number of cities -1

  Returns the chromosome with an uninitialised fitness variable
  """
  def new(length) when length > 0 do
      0..length - 1
      |> Enum.to_list
      |> (fn list -> from_list({list, nil}) end).()
  end

  def offspring(length) when length > 0 do
    %Individual{chromosome: Array.new(length)}
  end

  @doc """
  Creates an individual from a list.
  """
  def from_list({chromosome, fitness}) when is_list(chromosome) do
    %Individual{chromosome: chromosome |> Array.from_list, fitness: fitness}
  end

  @doc """
  Returns the chromosome contents of an individual as a list.
  """
  def to_list(%Individual{chromosome: chromosome, fitness: fitness}) do
    {chromosome |> Array.to_list, fitness}
  end


  def getFitness(%Individual{fitness: fitness}), do: fitness

  @doc """
  Retrieves the gene at the specified offset from the chromosome
  """
  def getGene(%Array{} = chromosome, offset) do
    Array.get(chromosome, offset)
  end


  @doc """
  Stores the gene at the specified offset in the chromosome.
  """
  def setGene(%Array{} = chromosome, offset, gene) do
    Array.set(chromosome, offset, gene)
  end


  @doc """
  Returns true if the chromosome contains the specified gene.
  """
  def containsGene?(%Array{} = chromosome, gene) do
    gene in chromosome
  end


  @doc """
  Swaps the genes at the given positions.
  """
  def swapGenes(%Array{} = chromosome, pos1, pos2) do
    tmp = chromosome |> getGene(pos1)

    chromosome
    |> setGene(pos1, chromosome |> getGene(pos2))
    |> setGene(pos2, tmp)
  end


  @doc """
  Mutates a chromosome's genes according to the mutation rate.
  """
  def mutate(%Individual{chromosome: chromosome} = individual, mutationRate) do
    chromosome_size = Array.size(chromosome)

    mutation =
      chromosome
      |> do_mutate(chromosome_size, mutationRate, chromosome_size - 1)

    %Individual{individual | chromosome: mutation}
  end

  defp do_mutate(chromosome, _, _, 0), do: chromosome
  defp do_mutate(chromosome, size, rate, pos) do
    if :rand.uniform < rate do
      new_pos = :rand.uniform(size) - 1
      do_mutate(swapGenes(chromosome, pos, new_pos), size, rate, pos - 1)
    else
      do_mutate(chromosome, size, rate, pos - 1)
    end
  end


  @doc """
  Shuffles the contents of the chromosome
  """
  def shuffle(%Individual{chromosome: chromosome} = individual) do
    %Individual{individual |
      chromosome: chromosome
          |> Enum.shuffle
          |> Array.from_list
    }
  end


  @doc """
  Returns the size of the array
  """
  def size(%Array{} = chromosome), do: Array.size(chromosome)

end
