defmodule Individual do

  def new(length) do
    for x <- 0..length-1, into: Array.new, do: x
  end

  def setGene(%Array{content: _c}=chromosome, offset, gene) do
    Array.set(chromosome, offset, gene)
  end

  def getGene(%Array{content: _c}=chromosome, offset) do
    Array.get(chromosome, offset)
  end

  def containsGene(%Array{content: _c}=chromosome, gene) do
    chromosome |> Enum.member?(gene)
  end

  def size(%Array{content: _c}=chromosome), do: Array.size(chromosome)

end