defmodule GeneticAlgorithmTest do
  use ExUnit.Case
  doctest GeneticAlgorithm
  import GeneticAlgorithm

  setup _context do
    population =
      Population.new(10)
      |> Enum.into(%{}, fn {key, ind} ->
        {key, Individual.shuffle(ind)}
      end)
      |> GeneticAlgorithm.evaluate

    {:ok, [population: population]}
  end

  test "Short distances are fitter than long distances" do
    bob = Individual.new(10)
    alice = Individual.new(20)  # Alice travels much further than bob

    assert updateFitness(bob).fitness > updateFitness(alice).fitness
  end

  test "Update the fitness for a population" do
    population = Population.new(2)

    # Make the individuals different
    population = put_in(population[0].chromosome[1], 2)

    new_population = evaluate(population)

    refute new_population[0].fitness == new_population[1].fitness
  end

  test "Elite population members are not subject to mutation" do
    elite_members = 3
    mutation_rate = 1
    population = Population.new(elite_members)

    new_population = mutate(population, elite_members, mutation_rate)
    assert population == new_population
  end

  test "All population members are subject to mutation" do
    elite_members = 0
    mutation_rate = 1
    population = Population.new(100)

    new_population = mutate(population, elite_members, mutation_rate)
    for index <- 0..99, do:
      refute population[index] == new_population[index]
  end

  test "Non-elite population members are subject to mutation" do
    elite_members = 3
    mutation_rate = 1
    # longer chromosomes are less likely to randomly mutate into themselves
    population = Population.new(elite_members+1, 10)

    new_population = mutate(population, elite_members, mutation_rate)
    refute population == new_population
  end

  test "Population members are not mutated when rate is 0" do
    elite_members = 0
    mutation_rate = 0
    population = Population.new(100)

    new_population = mutate(population, elite_members, mutation_rate)
    assert population == new_population
  end

  test "Offspring inherits genes from directly from its first parent" do
    parent1 = Individual.new(10)
    offspring1 = %{0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6,
    7 => 7, 8 => 8, 9 => 9}
    offspring2 = %{0 => nil, 1 => nil, 2 => nil, 3 => 3, 4 => 4, 5 => 5, 6 => 6,
    7 => 7, 8 => 8, 9 => nil}
    offspring3 = %{0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => nil, 5 => nil, 6 => nil,
    7 => nil, 8 => nil, 9 => nil}
    offspring4 = %{0 => nil, 1 => nil, 2 => nil, 3 => nil, 4 => 4, 5 => nil,
    6 => nil, 7 => nil, 8 => nil, 9 => nil}

    assert createOffspring(parent1.chromosome, 0, 9) == offspring1
    assert createOffspring(parent1.chromosome, 3, 8) == offspring2
    assert createOffspring(parent1.chromosome, 0, 3) == offspring3
    assert createOffspring(parent1.chromosome, 0, 3) == offspring3
    assert createOffspring(parent1.chromosome, 4, 4) == offspring4
  end

  test "Offspring inherit genes in an ordered mapping from its second parent" do
    parent2 = %{0 => 9, 1 => 8, 2 => 7, 3 => 6, 4 => 5, 5 => 4, 6 => 3,
    7 => 2, 8 => 1, 9 => 0}
    offspring1 = %{0 => nil, 1 => nil, 2 => nil, 3 => 3, 4 => 4, 5 => 5, 6 => 6,
    7 => 7, 8 => 8, 9 => nil}   # 3 to 8
    result1 = %{0 => 0, 1 => 9, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6,
    7 => 7, 8 => 8, 9 => 1}

    # 9, not 8,7,6,5,4,3, 2, 1, 0
    assert insertGenes(offspring1, parent2, 8) == result1

    offspring2 = %{0 => nil, 1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil,
    6 => nil, 7 => nil, 8 => nil, 9 => 3}   # 9
    result2 = %{0 => 9, 1 => 8, 2 => 7, 3 => 6, 4 => 5, 5 => 4, 6 => 2,
    7 => 1, 8 => 0, 9 => 3}

    #
    assert insertGenes(offspring2, parent2, 9) == result2
  end

  test "Ordered crossover takes genes from both parent chromosomes" do
    parent1 = %Individual{chromosome: %{0 => 2, 1 => 1, 2 => 7, 3 => 9, 4 => 5,
    5 => 6, 6 => 4, 7 => 3, 8 => 0, 9 => 8}, fitness: nil}
    parent2 = %Individual{chromosome: %{0 => 0, 1 => 7, 2 => 3, 3 => 9, 4 => 1,
    5 => 4, 6 => 5, 7 => 2, 8 => 6, 9 => 8}, fitness: nil}
    offspring = %Individual{chromosome: %{0 => 2, 1 => 8, 2 => 0, 3 => 9, 4 => 5,
    5 => 6, 6 => 4, 7 => 7, 8 => 3, 9 => 1}, fitness: nil}

   # Substring from parent1, plus ordered genes from parent2
   # [_, _, _, 9, 5, 6, 4, _, _, _] from parent1
   # (2, not 6, 8, 0, 7, 3, 1) from parent2
   assert crossover(parent1, parent2, 3, 6) == offspring
  end

  test "Elite population members do not experience crossover", context do
    population = context[:population]
    new_population = GeneticAlgorithm.crossover(population, 1, 10, 3)
    assert population == new_population
  end

  test "Population members are unchanged when crossover rate is zero", context do
    population = context[:population]
    new_population =
      GeneticAlgorithm.crossover(population, 0, 3, 3)

    assert population == new_population
  end

  test "Population members are changed when crossover rate is one", context do
    population = context[:population]
    new_population = GeneticAlgorithm.crossover(population, 1, 1, 3)

    refute population == new_population
  end

end
