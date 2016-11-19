defmodule Individual do
  defstruct chromosome: %{}, fitness: nil

  @doc """
  Creates a new chromosome of the specified length.
  City genes are in the range 0,1,2 .. number of cities -1

  Returns the chromosome with an uninitialised fitness variable
  """

  def new(length) when length > 0 do
    %Individual{chromosome: Enum.into(0..length-1, %{}, fn x -> {x, x} end)}
  end

  def offspring(length) when length > 0 do
    %Individual{chromosome: Enum.into(0..length-1, %{}, fn x -> {x, nil} end)}
  end

  @doc """
  Stores the gene at the specified offset in the chromosome.
  """

  def setGene(%{}=chromosome, offset, gene) do
    Map.update(chromosome, offset, nil, &(&1=gene))
  end

  @doc """
  Retrieves the gene at the specified offset from the chromosome
  """

  def getGene(%{}=chromosome, offset) do
    chromosome[offset]
  end

  @doc """
  Swap the genes at the given positions.
  """

def swapGenes(%{}=chromosome, pos1, pos2) do
  tmp = chromosome |> getGene(pos1)

  chromosome
  |> setGene(pos1, chromosome |> getGene(pos2))
  |> setGene(pos2, tmp)
end

  @doc """
  Mutates a chromosome's genes according to the mutation rate.
  """

  def mutate(%Individual{chromosome: chromosome}=individual, mutationRate) do
    chromosome_size = map_size(chromosome)

    mutation =
      chromosome
      |> do_mutate(chromosome_size, mutationRate, chromosome_size-1)

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
  Returns true if the chromosome contains the specified gene.
  """

  def containsGene?(%{}=chromosome, gene) do
    chromosome |> Enum.find_value(fn {_k, v} -> v == gene end)
  end

  @doc """
  Returns the size of the chromosome
  """

  def size(chromosome) when is_map(chromosome), do: map_size(chromosome)

  @doc """
  Shuffles the contents of the chromosome
  """

  def shuffle(%Individual{chromosome: chromosome}=individual) do
    %Individual{individual |
      chromosome: chromosome
        |> Map.keys
        |> Enum.shuffle
        |> Enum.zip(chromosome |> Map.values)
        |> Enum.into(%{})
    }
  end

end
