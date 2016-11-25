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
    offspring1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] |> Array.from_list
    offspring2 = [nil, nil, nil, 3, 4, 5, 6, 7, 8, nil] |> Array.from_list
    offspring3 = [0, 1, 2, 3, nil, nil, nil, nil, nil, nil] |> Array.from_list
    offspring4 = [nil, nil, nil, nil, 4, nil, nil, nil, nil, nil] |> Array.from_list

    # createOffpring returns fixed arrays
    assert createOffspring(parent1.chromosome, 0, 9) == offspring1 |> Array.fix
    assert createOffspring(parent1.chromosome, 3, 8) == offspring2 |> Array.fix
    assert createOffspring(parent1.chromosome, 0, 3) == offspring3 |> Array.fix
    assert createOffspring(parent1.chromosome, 0, 3) == offspring3 |> Array.fix
    assert createOffspring(parent1.chromosome, 4, 4) == offspring4 |> Array.fix
  end

  test "Offspring inherit genes in an ordered mapping from its second parent" do
    offspring = [nil, nil, nil, 3, 4, 5, 6, 7, 8, nil] |> Array.from_list   # 3 to 8
    parent = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] |> Array.from_list
    result = [0, 9, 2, 3, 4, 5, 6, 7, 8, 1] |> Array.from_list

    # 9, not 8,7,6,5,4,3, 2, 1, 0
    assert insertGenes(offspring, parent, 8+1) == result
  end

  test "insert genes into an offspring with a single gene at end" do
    offspring = [nil, nil, nil, nil, nil, nil, nil, nil, nil, 3] |> Array.from_list   # 9
    parent = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] |> Array.from_list
    result = [9, 8, 7, 6, 5, 4, 2, 1, 0, 3] |> Array.from_list

    assert insertGenes(offspring, parent, 9+1) == result
  end

  test "insert genes into offspring with multiple genes at end" do
    offspring = [nil, nil, nil, nil, nil, nil, nil, 8, 2, 5] |> Array.from_list   # 9
    parent = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] |> Array.from_list
    result = [9, 7, 6, 4, 3, 1, 0, 8, 2, 5] |> Array.from_list

    assert insertGenes(offspring, parent, 9+1) == result
  end

  test "insert genes into offspring with multiple genes in middle" do
    offspring = [nil, 4, 0, 8, nil, nil, nil, nil, nil, nil] |> Array.from_list   # 1 to 3
    parent = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] |> Array.from_list
    result = [5, 4, 0, 8, 3, 2, 1, 9, 7, 6] |> Array.from_list

    assert insertGenes(offspring, parent, 3+1) == result
  end

  test "Ordered crossover takes genes from both parent chromosomes" do
    parent1 = %Individual{
      chromosome: [2, 1, 7, 9, 5, 6, 4, 3, 0, 8] |> Array.from_list}
    parent2 = %Individual{
      chromosome: [0, 7, 3, 9, 1, 4, 5, 2, 6, 8] |> Array.from_list}
    offspring = %Individual{
      chromosome: [2, 8, 0, 9, 5, 6, 4, 7, 3, 1] |> Array.from_list |> Array.fix}

   # Substring from parent1, plus ordered genes from parent2
   # [_, _, _, 9, 5, 6, 4, _, _, _] from parent1
   # (2, not 6, 8, 0, 7, 3, 1) from parent2
   assert crossover(parent1, parent2, {3, 6}) == offspring
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
