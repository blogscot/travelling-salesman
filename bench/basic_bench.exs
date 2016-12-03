defmodule BasicBench do
  use Benchfella

  @individual Individual.new(100)
  @route Route.new(@individual)
  @population Population.new(100)

  bench "New" do
    Individual.mutate(@individual, 100, 0.001)
  end

end