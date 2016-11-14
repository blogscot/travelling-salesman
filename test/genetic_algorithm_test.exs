defmodule GeneticAlgorithmTest do
  use ExUnit.Case
  doctest GeneticAlgorithm
  import GeneticAlgorithm

  test "Short distances are fitter than long distances" do
    %Individual{chromosome: bob} = Individual.new(10)
    %Individual{chromosome: alice} = Individual.new(20)  # Alice travels much further than bob

    assert calcFitness(bob) > calcFitness(alice)
  end

  test "A population can be evaluated" do
    population_of_2 = Population.new(2)
    population_of_10 = Population.new(10)
    population_of_20 = Population.new(20)

    # As the population increases the total distance between
    # cities increases, and thus the average fitness decreases
    assert evaluate(population_of_2) == 0.013360676473519621
    assert evaluate(population_of_10) == 0.0029593918174858317
    assert evaluate(population_of_20) == 0.0012562399661038138
  end

end
