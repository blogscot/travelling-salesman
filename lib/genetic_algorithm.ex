defmodule GeneticAlgorithm do

  @moduledoc """
  Contains the genetic operators for the Travelling Salesman problem,
  evaluate, crossover and mutate.
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
  Calculates the fitness of a candidate solution.
  """

  def updateFitness(%Individual{}=individual) do
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

def evaluate(%Array{}=population) do
  population
  |> Enum.map(fn individual ->
    updateFitness(individual)
  end) |> Array.from_list
end

  @doc """
  Select a parent from the population using tournament selection.
  """

  def selectParent(%Array{}=population, tournamentSize) when tournamentSize > 0 do
    population
    |> Population.shuffle
    |> Enum.take(tournamentSize)
    |> Array.from_list
    |> Population.getFittest
  end

  @doc """
  Create a partial offspring chromosome with genes taken from the first parent
  using the given start and finish indices.
  """

  def createOffspring(%Array{}=parent_chromosome, start, finish) do
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

  def insertGenes(%{}=offspring, %{}=parent2, finish) do
    chromosome_size = Array.size(parent2)

    0..chromosome_size-1
    |> Enum.reduce(offspring, fn index, acc ->
      parent2_index = rem(index + finish, chromosome_size)
      parent2_gene = parent2 |> Individual.getGene(parent2_index)

      if acc |> Individual.containsGene?(parent2_gene) do
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

  def crossover(%Individual{chromosome: c1},
                %Individual{chromosome: c2}, {start, finish}) when start <= finish do

    # Copy substring from first parent into offspring
    offspring = createOffspring(c1, start, finish)

    # Insert remaining genes (in order) from parent2 into offspring
    offspring_chromosome = insertGenes(offspring, c2, finish+1)

    %Individual{chromosome: offspring_chromosome}
  end

  @doc """
  The genetic operator crossover is applied to members of the population
  by selecting two parents which then reproduce to create a new offspring,
  containing genetic material from both parents.
  """

  def crossover(%Array{}=population, crossoverRate, elitismCount, tournamentSize) do
    chromosome_size = population[0].chromosome |> Array.size
    sorted_population = population |> Population.sort

    elite_population =
      sorted_population
      |> Enum.take(elitismCount)

    crossover_population =
      sorted_population
      |> Stream.drop(elitismCount)
      |> Enum.map(fn parent1 ->
        if crossoverRate > :rand.uniform do
          parent2 = selectParent(population, tournamentSize)

          start_finish =
            Enum.min_max([:rand.uniform(chromosome_size)-1,
                          :rand.uniform(chromosome_size)-1])

          # Create offspring
          crossover(parent1, parent2, start_finish)
        else
          parent1
        end
      end)

    (elite_population ++ crossover_population) |> Array.from_list
  end

  @doc """
  Mutates members of the population according to the mutation rate.

  Note: the first n fittest members are allowed into the new population
  without mutation, where n = elitismCount.
  """

  def mutate(%Array{}=population, elitismCount, mutationRate) do
    sorted_population = population |> Population.sort

    elite = sorted_population |> Enum.take(elitismCount)

    non_elite =
      sorted_population
      |> Stream.drop(elitismCount)
      |> Enum.map(fn ind ->
        ind |> Individual.mutate(mutationRate)
      end)

    (elite ++ non_elite) |> Array.from_list
  end

end
