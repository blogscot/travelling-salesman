defmodule PopulationTest do
  use ExUnit.Case
  doctest Population

  test "Creating a new population works" do
    assert Population.new(20)
  end

  test "Creating a new population with a different chromosome length" do
    assert Population.new(20, 10)
  end

  test "Population members have the expected size" do
    expected_size = 20
    population = Population.new(expected_size)
    assert Individual.size(population[0].chromosome) == expected_size
  end

  test "Population members have the expect chromosome length" do
    population_size = 15
    expected_size = 25
    population = Population.new(population_size, expected_size)
    assert Individual.size(population[0].chromosome) == expected_size
  end

  test "An individual in the population can be replaced" do
    population_size = 50
    bob_size = 10
    position = 3
    population = Population.new(population_size)
    bob = Individual.new(bob_size)

    new_population = Population.setIndividual(bob, population, position)
    assert Individual.size(new_population[0].chromosome) == population_size
    assert Individual.size(new_population[position].chromosome) == bob_size
  end

  test "An individual in the population can be retrieved" do
    population_size = 44

    population = Population.new(population_size)
    alice = Population.getIndividual(population, population_size-1)
    assert Individual.size(alice.chromosome) == population_size  # using default chromosome length
  end

  test "A shuffled population contains individuals in a different order" do
    population_size = 69
    test_item1 = 3333
    test_item2 = 4444

    population = Population.new(population_size)

    # inject a few test items
    population = put_in(population[3].chromosome[3], test_item1)
    population = put_in(population[44].chromosome[44], test_item2)

    new_population = population |> Population.shuffle

    assert population[3].chromosome[3] == test_item1 &&
           population[44].chromosome[44] == test_item2
    refute new_population[3].chromosome[3] == test_item1 &&
           new_population[44].chromosome[44] == test_item2
  end

  test "A population has a size attribute" do
    population = Population.new(88)
    assert Population.size(population) == 88
  end
end