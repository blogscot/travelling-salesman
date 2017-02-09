defmodule EvaluationBench do
  use Benchfella

  def pop100, do: Population.new(100)
  def pop10, do: Population.new(10)

  bench "Evaluate a population of 100", [population: pop100()] do
    GeneticAlgorithm.evaluate(population)
  end

  bench "Evaluate a population of 10", [population: pop10()] do
    GeneticAlgorithm.evaluate(population)
  end

end
