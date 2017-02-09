defmodule CrossoverBench do
  use Benchfella

  @crossover_rate 0.95
  @mutation_rate 0.005
  @tournament_size 5

  def pop100, do: Population.new(100)
  def pop10, do: Population.new(10)

  bench "Crossover and mutate a population of 10", [population: pop10()] do
    population
    |> GeneticAlgorithm.crossover(10, @crossover_rate, @tournament_size)
    |> GeneticAlgorithm.mutate(@mutation_rate)
    nil  # required by Benchfella so that return value is deterministic
  end

  bench "Crossover and mutate a population of 100", [population: pop100()] do
    population
    |> GeneticAlgorithm.crossover(100, @crossover_rate, @tournament_size)
    |> GeneticAlgorithm.mutate(@mutation_rate)
    nil  # required by Benchfella so that return value is deterministic
  end

end
