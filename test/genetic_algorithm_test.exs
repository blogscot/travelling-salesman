defmodule GeneticAlgorithmTest do
  use ExUnit.Case
  doctest GeneticAlgorithm
  import GeneticAlgorithm

  test "Short distances are fitter than long distances" do
    bob = Individual.new(10)
    alice = Individual.new(20)  # Alice travels much further than bob

    assert updateFitness(bob).fitness > updateFitness(alice).fitness
  end

  test "Update the fitness for a population" do
    population = Population.new(2)

    # Make the individuals different
    population = put_in(population[0].chromosome[1], 2)

    new_population = updateFitness(population)

    refute new_population[0].fitness == new_population[1].fitness
  end

  test "Calculate the average fitness of a population (evaluation)" do
    population_of_2 = Population.new(2)
    population_of_10 = Population.new(10)
    population_of_20 = Population.new(20)

    # As the population increases the total distance between
    # cities increases, and thus the average fitness decreases
    assert evaluate(population_of_2) == 0.013360676473519621
    assert evaluate(population_of_10) == 0.0029593918174858317
    assert evaluate(population_of_20) == 0.0012562399661038138
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

  test "Ordered crossover takes genes from both parent chromosomes" do
    parent1 = %Individual{chromosome: %{0 => 2, 1 => 1, 2 => 7, 3 => 9, 4 => 5,
    5 => 6, 6 => 4, 7 => 3, 8 => 0, 9 => 8}, fitness: nil}
   parent2 = %Individual{chromosome: %{0 => 0, 1 => 7, 2 => 3, 3 => 9, 4 => 1,
   5 => 4, 6 => 5, 7 => 2, 8 => 6, 9 => 8}, fitness: nil}
   offspring_chromosome = %{0 => 2, 1 => 8, 2 => 0, 3 => 9, 4 => 5, 5 => 6,
   6 => 4, 7 => 7, 8 => 3, 9 => 1}

   # Substring from parent1, plus ordered genes from parent2
   # [_, _, _, 9, 5, 6, 4, _, _, _] from parent1
   # (2, not 6, 8, 0, 7, 3, 1) from parent2
   assert crossover(parent1, parent2, 3, 6) == offspring_chromosome
  end

end
