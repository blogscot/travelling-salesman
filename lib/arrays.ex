defmodule ArrayExamples do

  @doc """
  Creates an array of the given size with values equal to the
  index position, eg.

  #Array<[0, 1, 2, 3, 4, 5, 6, 7, 8, 9], fixed=true, default=0>

  iex(1)> ArrayExamples.new(10)
  #Array<[0, 1, 2, 3, 4, 5, 6, 7, 8, 9], fixed=false, default=nil>
  """

  def new(size) do
    for gene <- 0..size-1, into: Array.new, do: gene
  end

  @doc """
  Creates an array of given size with the a default value.

  iex(3)> ArrayExamples.new(10, 0)
  #Array<[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fixed=true, default=0>
  """

  def new(size, default) do
    Array.new([{:size, size}, {:default, default}])
  end

  @doc """
  Creates an array filled with nil values.

  iex(4)> ArrayExamples.offspring(10)
  #Array<[nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], fixed=true, default=nil>
  """

  def offspring(size), do: Array.new(size)

  @doc """
  Returns the value of the gene in the chromosome at the
  given position.
  """

  def getGene(%Array{}=chromosome, offset) do
    Array.get(chromosome, offset)
  end

  @doc """
  Sets the value of the given gene in the chromosome at the
  given position.
  """

  def setGene(%Array{}=chromosome, offset, gene) do
    Array.set(chromosome, offset, gene)
  end


  @doc """
  Swap the genes at the given positions.
  """

  def swapGenes(%Array{}=chromosome, pos1, pos2) do
    tmp = chromosome |> getGene(pos1)

    chromosome
    |> setGene(pos1, chromosome |> getGene(pos2))
    |> setGene(pos2, tmp)
  end

  def containsGene?(%Array{}=chromosome, gene) do
    chromosome |> Enum.member?(gene)
  end

  @doc """
  Mutates a chromosome's genes according to the mutation rate.
  """

  def mutate(%Array{}=chromosome, mutationRate) do
    chromosome_size = Array.size(chromosome)

    chromosome
    |> do_mutate(chromosome_size, mutationRate, chromosome_size-1)
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

  def shuffle(%Array{}=chromosome) do
    chromosome
    |> Array.to_list
    |> Enum.shuffle
    |> Array.from_list
  end

  @doc """
  Return the size of the array
  """

  def size(%Array{}=chromosome), do: Array.size(chromosome)
end