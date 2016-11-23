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

def evaluate(%{}=population) do
  population
  |> Stream.map(fn {key, individual} ->
    {key, updateFitness(individual)}
  end) |> Enum.into(%{})
end

  @doc """
  Select a parent from the population using tournament selection.
  """

  def selectParent(%{}=population, tournamentSize) when tournamentSize > 0 do
    population
    |> Population.shuffle
    |> Enum.take(tournamentSize)
    |> Enum.into(%{})
    |> Population.getFittest
  end

  @doc """
  Create a partial offspring chromosome with genes taken from the first parent
  using the given start and finish indices.
  """

  def createOffspring(%{}=parent1, start, finish) do
    offspring = Individual.offspring(map_size(parent1))

    offspring.chromosome
    |> Enum.map(fn {key, value} ->
      if key in start..finish do
        {key, parent1 |> Individual.getGene(key)}
      else
        {key, value}
      end
    end) |> Enum.into(%{})
  end

  @doc """
  Inserts genes from the second parent into a partial offspring (i.e. genes
  from first parent only) while preserving the gene ordering in the second
  parent (ordered crossover).

  finish   the last gene position in offspring taken from parent1.
  """

  def insertGenes(%{}=offspring, %{}=parent2, finish) do
    chromosome_size = map_size(parent2)

    0..chromosome_size-1
    |> Enum.reduce(offspring, fn key, acc ->
      # IO.inspect("Acc: #{inspect acc}")
      parent2_key = rem(key + finish + 1, chromosome_size)
      parent2_gene = parent2 |> Individual.getGene(parent2_key)

      # IO.write("#{parent2_gene} ")
      if acc |> Individual.containsGene?(parent2_gene) do
        acc
      else
        # find the index of the first nil value
        offspring_index = acc |> Enum.find_index(fn {_k, v} -> v == nil end)
        # IO.write("#{offspring_index} ")
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
                %Individual{chromosome: c2}, start, finish) when start <= finish do

    # Copy substring from first parent into offspring
    offspring = createOffspring(c1, start, finish)

    # Insert remaining genes (in order) from parent2 into offspring
    offspring_chromosome = insertGenes(offspring, c2, finish)

    # IO.inspect("Offspring2 #{inspect offspring_chromosome}, #{start}, #{finish}")
    %Individual{chromosome: offspring_chromosome}
  end

  @doc """
  The genetic operator crossover is applied to members of the population
  by selecting two parents which then reproduce to create a new offspring,
  containing genetic material from both parents.
  """

  def crossover(%{}=population, crossoverRate, elitismCount, tournamentSize) do
    sorted_population = population |> Population.sort

    elite_population =
      sorted_population
      |> Stream.take(elitismCount)
      |> Enum.into(%{})

    chromosome_size =
      population
      |> Population.getIndividual(0)
      |> (fn ind -> map_size(ind.chromosome) end).()

    crossover_population =
      sorted_population
      |> Stream.drop(elitismCount)
      |> Enum.map(fn {key, parent1} ->
        if crossoverRate > :rand.uniform do
          parent2 = selectParent(population, tournamentSize)

          {start, finish} =
            Enum.min_max([:rand.uniform(chromosome_size)-1,
                          :rand.uniform(chromosome_size)-1])

          # Create offspring
          offspring = crossover(parent1, parent2, start, finish)
          {key, offspring}
        else
          {key, parent1}
        end
      end) |> Enum.into(%{})

    Map.merge(elite_population, crossover_population)
  end

  @doc """
  Mutates members of the population according to the mutation rate.

  Note: the first n fittest members are allowed into the new population
  without mutation, where n = elitismCount.
  """

  def mutate(%{}=population, elitismCount, mutationRate) do
    sorted_population = population |> Population.sort

    elite = sorted_population |> Stream.take(elitismCount) |> Enum.into(%{})

    non_elite =
      sorted_population
      |> Stream.drop(elitismCount)
      |> Stream.map(fn {key, ind} ->
        {key, ind |> Individual.mutate(mutationRate)}
      end) |> Enum.into(%{})

    Map.merge(elite, non_elite)
  end

end
