defmodule PopulationTest do
  use ExUnit.Case
  doctest Population

  test "Creating a new population works" do
    assert Population.new(20)
  end

  test "Creating a new population with a different chromosome length" do
    assert Population.new(20, 10)
  end

  test "A population can be converted into a list of chromosome lists"  do
    population = Population.new(10)
    chromosomes = population |> Population.to_list

    assert chromosomes |> List.first == {[0,1,2,3,4,5,6,7,8,9], nil}
    assert chromosomes |> length == 10
  end

  test "A list of chromsome lists can be converted into a standard population" do
    population = Population.new(60)

    assert population |> Population.to_list |> Population.from_list == population
  end

  test "A list converted to a population can be converted back" do
    my_list = for _ <- 0..9, do: {[0,1,2,3,4,5,6,7,8,9], nil}
    new_population = my_list |> Population.from_list

    assert new_population |> Population.to_list == my_list
  end

  test "Population members have the expected size" do
    expected_size = 20
    population = Population.new(expected_size) |> Array.from_list
    assert Array.size(population[0].chromosome) == expected_size
  end

  test "Population members have the expect chromosome length" do
    population_size = 15
    expected_size = 25
    population = Population.new(population_size, expected_size) |> Array.from_list
    assert Array.size(population[0].chromosome) == expected_size
  end

  test "An individual in the population can be replaced" do
    population_size = 50
    bob_size = 10
    position = 3
    population = Population.new(population_size) |> Array.from_list
    bob = Individual.new(bob_size)

    new_population = Population.setIndividual(population, bob, position)
    assert Array.size(new_population[0].chromosome) == population_size
    assert Array.size(new_population[position].chromosome) == bob_size
  end

  test "An individual in the population can be retrieved" do
    population_size = 44

    population = Population.new(population_size) |> Array.from_list
    alice = Population.getIndividual(population, population_size-1)
    assert Array.size(alice.chromosome) == population_size  # using default chromosome length
  end

  test "A shuffled population contains individuals in a different order" do
    population_size = 69
    test_item1 = 3333
    test_item2 = 4444

    population = Population.new(population_size) |> Array.from_list

    # inject a few test items
    population = put_in(population[3].chromosome[3], test_item1)
    population = put_in(population[44].chromosome[44], test_item2)

    new_population =
      population
      |> Population.shuffle
      |> Array.from_list

    assert population[3].chromosome[3] == test_item1 &&
           population[44].chromosome[44] == test_item2
    refute new_population[3].chromosome[3] == test_item1 &&
           new_population[44].chromosome[44] == test_item2
  end

  test "A population has a fittest individual" do
    population = Population.new(3) |> Array.from_list

    # Make the individuals different
    bob = population[1].chromosome |> Individual.setGene(2, 4)
    alice = population[2].chromosome |> Individual.setGene(2, 8)

    changed_pop =
      population
      |> Population.setIndividual(%Individual{chromosome: bob}, 1)
      |> Population.setIndividual(%Individual{chromosome: alice}, 2)

    # Evaluate each individual's fitness
    new_pop = GeneticAlgorithm.evaluate(changed_pop)

    assert %Individual{fitness: fitness1} = new_pop |> Population.getFittest
    assert %Individual{fitness: fitness2} = new_pop |> Population.getFittest(1)
    assert %Individual{fitness: fitness3} = new_pop |> Population.getFittest(2)

    assert fitness1 === 0.010499504733954064
    assert fitness2 === 0.01028730494505273
    assert fitness3 === 0.008489805347921537
  end

  test "A population provides basic statistics" do
    population = Population.new(3) |> Array.from_list

    # Make the individuals different
    bob = population[1].chromosome |> Individual.setGene(2, 4)
    alice = population[2].chromosome |> Individual.setGene(2, 8)

    changed_pop =
      population
      |> Population.setIndividual(%Individual{chromosome: bob}, 1)
      |> Population.setIndividual(%Individual{chromosome: alice}, 2)

    # Evaluate each individual's fitness
    new_pop = GeneticAlgorithm.evaluate(changed_pop)

    assert new_pop |> Population.maxFitness == 0.010499504733954064
    assert new_pop |> Population.avgFitness == 0.009758871675642775
  end
end
