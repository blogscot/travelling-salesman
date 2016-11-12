defmodule Individual do

  @doc """
  Creates a new chromosome of the specified length.
  """

  def new(length) when length > 0 do
    0..length-1
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, x, &(&1)) end)
  end

  @doc """
  Stores the gene at the specified offset in the chromosome.
  """

  def setGene(chromosome, offset, gene) when is_map(chromosome) do
    Map.update(chromosome, offset, nil, &(&1=gene))
  end

  @doc """
  Retrieves the gene at the specified offset from the chromosome
  """

  def getGene(chromosome, offset) when is_map(chromosome) do
    chromosome[offset]
  end

  @doc """
  Returns true if the chromosome contains the specified gene.

  Note: the map keys and values contain the complete list of genes
        so it sufficient to just check the keys.
  """

  def containsGene(chromosome, gene) when is_map(chromosome) do
    chromosome
    |> Map.has_key?(gene)
  end

  @doc """
  Returns the size of the chromosome
  """

  def size(chromosome) when is_map(chromosome), do:
    chromosome |> Map.to_list |> length

end