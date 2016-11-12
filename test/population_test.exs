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
    assert Individual.size(population[0]) == expected_size
  end

  test "Population members have the expect chromosome length" do
    population_size = 15
    expected_size = 25
    population = Population.new(population_size, expected_size)
    assert Individual.size(population[0]) == expected_size
  end

  test "An individual in the population can be replaced" do
    population_size = 50
    bob_size = 10
    position = 3
    population = Population.new(population_size)
    bob = Individual.new(bob_size)

    new_population = Population.setIndividual(bob, population, position)
    assert Individual.size(new_population[0]) == population_size
    assert Individual.size(new_population[position]) == bob_size
  end

  test "An individual in the population can be retrieved" do
    population_size = 44

    population = Population.new(population_size)
    alice = Population.getIndividual(population, population_size-1)
    assert Individual.size(alice) == population_size  # using default chromosome length
  end

  test "A shuffled population contains the same individuals" do
    population_size = 69
    population = Population.new(population_size)
    keys = Map.keys(population)

    new_population = population |> Population.shuffle
    new_keys = new_population |> Map.keys
    assert keys |> Enum.sort == new_keys |> Enum.sort
    assert population |> Population.size == new_population |> Population.size

    # Both populations are non-random so the contents are equivalent
    assert population[0] == new_population[population_size-1]
  end

  test "A population has a size attribute" do
    population = Population.new(88)
    assert Population.size(population) == 88
  end
end