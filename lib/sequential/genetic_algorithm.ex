defmodule GeneticAlgorithm do

  @moduledoc """
  Contains the genetic operators for the Travelling Salesman problem,
  evaluate, crossover and mutate.
  """


  @doc """
  Calculates the fitness of a candidate solution.
  """
  def updateFitness(%Individual{} = individual) do
    distance =
      individual
      |> Route.new
      |> Route.getDistance

    # short distances are fitter than long distances
    %Individual{individual | fitness:  1 / distance}
  end


  @doc """
  Updates the fitness for each member of the population.
  """
  def evaluate(population) do
    population
    |> Enum.map(&updateFitness(&1))
  end


  @doc """
  Selects a parent from the population using tournament selection.
  """
  def selectParent(population, tournamentSize) when tournamentSize > 0 do
    population
    |> Population.shuffle
    |> Enum.take(tournamentSize)
    |> Population.getFittest
  end


  @doc """
  Creates a partial offspring chromosome with genes taken from the first parent
  using the given start and finish indices.
  """
  def createOffspring(%Array{} = parent_chromosome, start, finish) do
    size = Array.size(parent_chromosome)
    offspring = Individual.offspring(size)

    start..finish
    |> Enum.reduce(offspring.chromosome, fn index, acc ->
      if index in start..finish do
        parent_gene = parent_chromosome |> Individual.getGene(index)
        acc |> Individual.setGene(index, parent_gene)
      else
        acc
      end
    end)
  end


  @doc """
  Inserts genes from the second parent into a partial offspring (i.e. genes
  from first parent only) while preserving the gene ordering in the second
  parent (ordered crossover).

  finish   the first empty gene position following parent1 substring.
  """
  def insertGenes(%{} = offspring, %{} = parent2) do

    parent2
    |> Enum.reduce(offspring, fn parent2_gene, acc ->
      if parent2_gene in acc do
        acc
      else
        # find the index of the first nil value
        offspring_index = acc |> Enum.find_index(&is_nil/1)
        # copy the missing value into offspring
        acc |> Individual.setGene(offspring_index, parent2_gene)
      end
    end)
  end


  @doc """
  Applies the genetic crossover operator to two parents producing a
  single offspring.
  """
  def crossover(%Individual{chromosome: c1}, %Individual{chromosome: c2},
                {start, finish}) when start <= finish do

    # Copy substring from first parent into offspring
    offspring = createOffspring(c1, start, finish)

    # Insert remaining genes (in order) from parent2 into offspring
    offspring_chromosome = insertGenes(offspring, c2)
    %Individual{chromosome: offspring_chromosome}
  end


  @doc """
  Applies genetic operator crossover to members of the population
  by selecting two parents which then reproduce to create a new offspring,
  containing genetic material from both parents.
  """
  def crossover(population, chromosome_size, crossoverRate, tournamentSize) do

    population
    |> Enum.map(fn parent1 ->
      if crossoverRate > :rand.uniform do
        parent2 = selectParent(population, tournamentSize)

        start_finish =
          Enum.min_max([:rand.uniform(chromosome_size) - 1,
                        :rand.uniform(chromosome_size) - 1])

        # Create offspring
        crossover(parent1, parent2, start_finish)
      else
        parent1
      end
    end)
  end


  @doc """
  Mutates members of the population according to the mutation rate.

  Note: the first n fittest members are allowed into the new population
  without mutation, where n = elitismCount.
  """
  def mutate(population, mutationRate) do
    population
    |> Enum.map(fn ind ->
      ind |> Individual.mutate(mutationRate)
    end)
  end

end
